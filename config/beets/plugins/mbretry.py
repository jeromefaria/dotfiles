"""
Beets plugin to add automatic retry logic for MusicBrainz API failures.

This plugin addresses the issue where MusicBrainz API returns XML parsing errors
and network failures due to high server load. It implements exponential backoff
with jitter to automatically retry failed requests.

Author: Jerome Faria
License: MIT
"""

from beets.plugins import BeetsPlugin
import musicbrainzngs
from musicbrainzngs import musicbrainz
import time
import random
import logging
from functools import wraps


class MBRetryPlugin(BeetsPlugin):
    """Plugin to add retry logic to MusicBrainz API requests."""

    def __init__(self):
        super(MBRetryPlugin, self).__init__()

        # Set default configuration
        self.config.add({
            'max_retries': 3,
            'initial_delay': 5,
            'max_delay': 60,
            'backoff_strategy': 'exponential',
            'backoff_multiplier': 2,
            'jitter': True,
            'jitter_range': 0.1,
            'retry_on_errors': [
                'NetworkError',
                'ResponseError',
                'WebServiceError',
                'timeout'
            ],
            'log_retries': True,
            'log_level': 'info',
            'respect_ratelimit': True
        })

        # Patch musicbrainzngs to add retry logic
        self._patch_musicbrainzngs()

        self._log.debug('MusicBrainz retry plugin initialized')

    def _patch_musicbrainzngs(self):
        """
        Monkey patch musicbrainz._mb_request() to add retry logic.

        This is the central function that all MusicBrainz API calls go through,
        so patching it allows us to intercept and retry all requests.
        """
        if not hasattr(musicbrainz, '_mb_request'):
            self._log.warning('musicbrainz._mb_request not found, skipping patch')
            return

        # Store original function
        original_request = musicbrainz._mb_request

        # Create wrapper with retry logic
        @wraps(original_request)
        def retry_wrapper(*args, **kwargs):
            return self._retry_request(original_request, *args, **kwargs)

        # Replace the function
        musicbrainz._mb_request = retry_wrapper
        self._log.debug('Successfully patched musicbrainz._mb_request')

    def _retry_request(self, func, *args, **kwargs):
        """
        Execute a request with retry logic and exponential backoff.

        Args:
            func: The original request function to call
            *args: Positional arguments for the function
            **kwargs: Keyword arguments for the function

        Returns:
            The result of the successful request

        Raises:
            The last exception if all retries fail
        """
        max_retries = self.config['max_retries'].get()
        total_delay = 0.0

        for attempt in range(max_retries + 1):
            try:
                # Attempt the request
                result = func(*args, **kwargs)

                # Log success if we had to retry
                if attempt > 0 and self.config['log_retries'].get():
                    self._log.info(
                        f'MusicBrainz request succeeded after {attempt} '
                        f'{"retry" if attempt == 1 else "retries"} '
                        f'(total delay: {total_delay:.1f}s)'
                    )

                return result

            except Exception as e:
                # Check if we should retry this error
                if not self._is_retryable(e):
                    self._log.debug(
                        f'Non-retryable error encountered: {e.__class__.__name__}: {e}'
                    )
                    raise

                # Check if we've exhausted retries
                if attempt >= max_retries:
                    self._log.warning(
                        f'MusicBrainz request failed after {max_retries} retries '
                        f'(total delay: {total_delay:.1f}s): {e.__class__.__name__}: {e}'
                    )
                    raise

                # Calculate backoff delay
                delay = self._calculate_backoff(attempt)
                total_delay += delay

                # Log retry attempt
                if self.config['log_retries'].get():
                    remaining = max_retries - attempt
                    self._log.info(
                        f'MusicBrainz retry {attempt + 1}/{max_retries} '
                        f'({e.__class__.__name__}). '
                        f'Waiting {delay:.1f}s... '
                        f'({remaining} {"retry" if remaining == 1 else "retries"} remaining)'
                    )
                else:
                    self._log.debug(
                        f'Retry attempt {attempt + 1}: {e.__class__.__name__}: {e}'
                    )

                # Wait before retrying
                time.sleep(delay)

    def _calculate_backoff(self, attempt):
        """
        Calculate the delay before the next retry attempt.

        Args:
            attempt: The current attempt number (0-indexed)

        Returns:
            float: The delay in seconds
        """
        strategy = self.config['backoff_strategy'].get()
        initial_delay = self.config['initial_delay'].get()
        max_delay = self.config['max_delay'].get()
        multiplier = self.config['backoff_multiplier'].get()

        # Calculate base delay based on strategy
        if strategy == 'exponential':
            # Exponential: initial * (multiplier ^ attempt)
            delay = initial_delay * (multiplier ** attempt)
        elif strategy == 'linear':
            # Linear: initial + (initial * attempt)
            delay = initial_delay * (1 + attempt)
        elif strategy == 'fixed':
            # Fixed: always use initial delay
            delay = initial_delay
        else:
            # Default to exponential
            self._log.warning(f'Unknown backoff strategy: {strategy}, using exponential')
            delay = initial_delay * (multiplier ** attempt)

        # Cap at maximum delay
        delay = min(delay, max_delay)

        # Add jitter if enabled
        if self.config['jitter'].get():
            jitter_range = self.config['jitter_range'].get()
            jitter_amount = delay * jitter_range
            # Add random jitter: ±jitter_range% of delay
            jitter = random.uniform(-jitter_amount, jitter_amount)
            delay += jitter

        # Ensure minimum delay of 1 second
        delay = max(delay, 1.0)

        return delay

    def _is_retryable(self, exception):
        """
        Determine if an exception should trigger a retry.

        Args:
            exception: The exception to check

        Returns:
            bool: True if the exception is retryable, False otherwise
        """
        retry_on = self.config['retry_on_errors'].get()

        # Get exception class name
        exception_name = exception.__class__.__name__

        # Check if this exception type is in the retry list
        if exception_name in retry_on:
            return True

        # Special handling for specific exception types
        # NetworkError - connection failures, timeouts
        if 'NetworkError' in retry_on and isinstance(exception, getattr(musicbrainzngs, 'NetworkError', type(None))):
            return True

        # ResponseError - XML parsing errors (main issue from #3306)
        if 'ResponseError' in retry_on and isinstance(exception, getattr(musicbrainzngs, 'ResponseError', type(None))):
            return True

        # WebServiceError - temporary server errors (500, 503)
        if 'WebServiceError' in retry_on and isinstance(exception, getattr(musicbrainzngs, 'WebServiceError', type(None))):
            # Check status code if available
            if hasattr(exception, 'cause') and hasattr(exception.cause, 'code'):
                code = exception.cause.code
                # Retry on server errors (5xx) but not client errors (4xx)
                if code >= 500:
                    return True
                elif code >= 400:
                    return False
            return True

        # Timeout exceptions
        if 'timeout' in retry_on:
            # Check for timeout in exception message or type
            exception_str = str(exception).lower()
            if 'timeout' in exception_str or 'timed out' in exception_str:
                return True

        # Non-retryable errors (fail immediately)
        non_retryable_types = [
            'AuthenticationError',  # Invalid credentials
            'InvalidSearchFieldError',  # API misuse
        ]

        if exception_name in non_retryable_types:
            return False

        # Check for HTTP 404 (Not Found) or 400 (Bad Request)
        if hasattr(exception, 'cause') and hasattr(exception.cause, 'code'):
            code = exception.cause.code
            if code in [400, 404]:
                return False

        # Default: don't retry unknown errors
        self._log.debug(
            f'Unknown exception type, not retrying: {exception_name}: {exception}'
        )
        return False

    def commands(self):
        """Provide plugin commands (none for this plugin)."""
        return []
