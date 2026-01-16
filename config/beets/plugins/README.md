# Beets Custom Plugins

This directory contains custom plugins for the [beets](https://beets.io/) music library manager.

## Plugins

### mbretry - MusicBrainz Retry Plugin

Implements automatic retry logic for MusicBrainz API failures with exponential backoff.

#### Purpose

The MusicBrainz API occasionally returns errors due to:
- Network timeouts and connection failures
- XML parsing errors (see [beets issue #3306](https://github.com/beetbox/beets/issues/3306))
- Temporary server overload from high traffic
- Rate limiting and throttling

This plugin automatically retries failed requests instead of requiring manual intervention, making the import process more reliable and hands-off.

#### Features

- **Automatic retry logic** - Intercepts all MusicBrainz API calls via monkey patching
- **Exponential backoff** - Increases delay between retries: 5s → 10s → 20s (configurable)
- **Jitter support** - Adds randomization (±10%) to prevent synchronized retry storms
- **Smart error classification** - Only retries transient errors, fails fast on permanent errors
- **Rate limit respect** - Works alongside existing beets rate limiting
- **Comprehensive logging** - Logs retry attempts and outcomes for visibility
- **Highly configurable** - Adjust retries, delays, strategies, and error types

#### Installation

1. The plugin is already installed in this dotfiles repository at:
   ```
   /Users/jeromefaria/dotfiles/config/beets/plugins/mbretry.py
   ```

2. Configuration has been added to `config/beets/config.yaml`

3. The plugin is enabled and will load automatically when beets starts.

**Note:** Custom beets plugins should be placed directly in the `pluginpath` directory, not in a `beetsplug` subdirectory. The `beetsplug` namespace is reserved for plugins installed in the Python environment.

#### Configuration

The plugin is configured in your beets config files:

```yaml
# Enable the plugin
plugins: mbretry musicbrainz discogs ...

# Set plugin path
pluginpath:
  - /Users/jeromefaria/dotfiles/config/beets/plugins

# Configure retry behavior
mbretry:
  max_retries: 3              # Maximum retry attempts (default: 3)
  initial_delay: 5            # Initial delay in seconds (default: 5)
  max_delay: 60               # Maximum delay between retries (default: 60)
  backoff_strategy: exponential  # exponential, linear, or fixed (default: exponential)
  backoff_multiplier: 2       # Exponential backoff multiplier (default: 2)
  jitter: true                # Add random jitter to delays (default: true)
  jitter_range: 0.1           # Jitter as ±10% of delay (default: 0.1)
  retry_on_errors:            # Error types to retry (default: see below)
    - NetworkError
    - ResponseError
    - WebServiceError
    - timeout
  log_retries: true           # Log retry attempts (default: true)
  log_level: info             # debug, info, or warning (default: info)
  respect_ratelimit: true     # Honor existing rate limits (default: true)
```

##### Configuration Options Explained

**max_retries** - How many times to retry before giving up (0 = no retries, 3 = default)

**initial_delay** - Starting delay in seconds before first retry
- FLAC config: 5 seconds (respects 10s rate limit)
- MP3 config: 2 seconds (respects 1s rate limit)

**max_delay** - Cap on maximum delay to prevent excessively long waits

**backoff_strategy** - How delay increases with each retry:
- `exponential`: Delay doubles each time (5s → 10s → 20s → 40s)
- `linear`: Delay increases linearly (5s → 10s → 15s → 20s)
- `fixed`: Same delay every time (5s → 5s → 5s → 5s)

**backoff_multiplier** - Multiplier for exponential backoff (2 = double each time)

**jitter** - Adds randomness to prevent synchronized retries from multiple processes

**jitter_range** - Amount of randomness (0.1 = ±10% of calculated delay)

**retry_on_errors** - Which error types trigger retries:
- `NetworkError`: Connection timeouts, DNS failures
- `ResponseError`: XML parsing errors (main issue from beets #3306)
- `WebServiceError`: Temporary server errors (500, 503)
- `timeout`: Request timeout exceptions

**log_retries** - Whether to log retry attempts to console

**log_level** - Verbosity of logging:
- `debug`: Full exception details and request parameters
- `info`: Retry attempts and final outcomes (recommended)
- `warning`: Only warnings when approaching max retries

#### Usage

The plugin works automatically once enabled. No special commands needed.

During import, if MusicBrainz fails, you'll see log messages like:

```
mbretry: MusicBrainz retry 1/3 (ResponseError). Waiting 5.2s... (2 retries remaining)
mbretry: MusicBrainz retry 2/3 (NetworkError). Waiting 10.7s... (1 retry remaining)
mbretry: MusicBrainz request succeeded after 2 retries (total delay: 16.3s)
```

Normal imports (no errors) will not show any retry messages.

#### How It Works

The plugin uses monkey patching to intercept all MusicBrainz API requests:

1. On plugin load, replaces `musicbrainzngs._mb_request()` with a wrapper function
2. The wrapper calls the original function and catches exceptions
3. If an exception is retryable (network error, XML parse error, timeout):
   - Calculates delay using exponential backoff: `initial_delay * (2 ^ attempt)`
   - Adds random jitter to prevent synchronized retries
   - Waits for the calculated delay
   - Retries the request
4. If the exception is not retryable (404, auth error), fails immediately
5. After `max_retries` attempts, gives up and re-raises the last exception

#### Error Classification

**Retryable errors** (will retry automatically):
- `NetworkError` - Connection timeouts, DNS failures, network interruptions
- `ResponseError` - XML parsing errors, malformed responses
- `WebServiceError` - Server errors (HTTP 500, 503)
- Timeout exceptions - Request took too long

**Non-retryable errors** (fail immediately):
- `AuthenticationError` - Invalid credentials
- `InvalidSearchFieldError` - API misuse, bad query syntax
- HTTP 404 - Resource not found
- HTTP 400 - Bad request

This classification prevents wasting time retrying errors that will never succeed.

#### Backoff Examples

With default settings (initial_delay=5, multiplier=2, jitter=true):

**Attempt 1**: 5s × 2^0 = 5s ± 0.5s → ~4.5-5.5s
**Attempt 2**: 5s × 2^1 = 10s ± 1.0s → ~9-11s
**Attempt 3**: 5s × 2^2 = 20s ± 2.0s → ~18-22s
**Total**: ~32-39 seconds across 3 retries

#### Troubleshooting

**Plugin not loading**
```bash
# Check beets recognizes the plugin
beet version

# Check for plugin errors
beet -vv config
```

**No retry messages appearing**
- If imports succeed normally, retries aren't needed (good!)
- Enable debug logging: `log_level: debug` in mbretry config
- Use verbose mode: `beet -vv import ...`

**Retries still failing**
- Increase `max_retries` (try 5 or 10)
- Increase `initial_delay` (try 10 or 15 seconds)
- Check MusicBrainz status: https://metabrainz.org/
- Consider using Discogs as fallback data source

**Imports taking too long**
- Reduce `max_retries` (try 2 instead of 3)
- Reduce `initial_delay` (try 3 instead of 5)
- Use `backoff_strategy: linear` for more predictable timing

**Want to disable temporarily**
```yaml
# Remove mbretry from plugins list
plugins: musicbrainz discogs lastgenre ...
```

#### Testing

To verify the plugin is working:

```bash
# Check plugin loads
beet version

# View configuration
beet config

# Test import with verbose logging
beet -vv import /path/to/album

# Watch for retry messages if MusicBrainz fails
```

#### Performance Impact

- **No errors**: Zero overhead, requests pass through normally
- **With retries**: Adds configured delay (5-20s per retry by default)
- **Memory**: Minimal, just function wrapping
- **CPU**: Negligible, simple calculations

#### Compatibility

- Tested with beets 1.6+
- Works with Python 3.7+
- Compatible with all other beets plugins
- No external dependencies beyond beets and musicbrainzngs

#### Future Enhancements

Potential improvements:
- Circuit breaker pattern (stop after X consecutive failures)
- Retry statistics tracking (`beet mbretry stats`)
- Adaptive rate limiting based on error rates
- Automatic Discogs fallback when MusicBrainz fails completely

#### License

MIT License - Free to use and modify

#### Credits

Created by Jerome Faria to address MusicBrainz reliability issues.

Addresses beets issue [#3306](https://github.com/beetbox/beets/issues/3306) and community reports of MusicBrainz XML parsing errors.

#### Support

For issues or questions:
1. Check the troubleshooting section above
2. Review beets documentation: https://beets.readthedocs.io/
3. Search beets issues: https://github.com/beetbox/beets/issues
