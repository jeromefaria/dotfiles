# Neomutt Keybindings Cheat Sheet

## Leader Key: `,` (comma)
Matches Neovim classic mode configuration.

## Basic Navigation (Index)
| Key | Action |
|-----|--------|
| `j` | Next entry |
| `k` | Previous entry |
| `gg` | First entry |
| `G` | Last entry |
| `l` | Display/open message |
| `h` | (unbound) |
| `Space` | **Tag/select message** |
| `L` | Limit/filter messages |

## Basic Navigation (Pager)
| Key | Action |
|-----|--------|
| `j` | Next line |
| `k` | Previous line |
| `gg` | Top of message |
| `G` | Bottom of message |
| `h` | Exit pager |
| `l` | View attachments |
| `H` | View raw message |

## Message Actions (Leader)
| Key | Action |
|-----|--------|
| `,s` | Sync mailbox |
| `,r` | Reply all (group-reply) |
| `,f` | Forward message |
| `,d` | Delete message |
| `,u` | Undelete message |
| `D` | Delete (in pager) |
| `U` | Undelete (in pager) |
| `Ctrl-d` | Purge message |

## View/Navigation (Leader)
| Key | Action |
|-----|--------|
| `,v` | View attachments |
| `,h` | View raw message/headers |
| `,t` | Tag message |
| `,T` | Tag thread |

## Compose (Leader)
| Key | Action |
|-----|--------|
| `,c` | Compose new message |
| `,@` | Compose to sender |
| `@` | Compose to sender (direct) |
| `P` | Recall draft (index) / Postpone (compose) |

## Search/Filter (Leader)
| Key | Action |
|-----|--------|
| `,/` | Limit/filter |
| `A` | Show all messages (clear limit) |
| `,n` | Next search result |
| `,N` | Previous search result |
| `N` | Search opposite direction |

## Gmail Operations (Leader)
| Key | Action |
|-----|--------|
| `,ga` | Archive (move to All Mail) |
| `,gd` | Move to Drafts |
| `,gs` | Mark as spam |
| `gm` | Fuzzy mailbox switcher (FZF) |

## Address Book (Leader)
| Key | Action |
|-----|--------|
| `,a` | Add sender to address book |
| `,A` | Create mutt alias |

## Special (Leader)
| Key | Action |
|-----|--------|
| `,q` | Quit neomutt |
| `,R` | Recall draft |
| `,P` | Print message |
| `,p` | Command palette |
| `,U` | Extract URLs (urlview) |

## Sidebar
| Key | Action |
|-----|--------|
| `Ctrl-k` | Previous mailbox |
| `Ctrl-j` | Next mailbox |
| `Ctrl-o` | Open mailbox |
| `Ctrl-p` | Previous new |
| `Ctrl-n` | Next new |
| `B` | Toggle sidebar |

## Function Keys
| Key | Action |
|-----|--------|
| `F1` | Reload configuration |
| `F2` | Limit to unread |
| `F3` | Limit to flagged |
| `F4` | Limit to bills/services |
| `F5` | Limit to orders |
| `F6` | Limit to PayPal |

## Other
| Key | Action |
|-----|--------|
| `S` | Sync mailbox |
| `R` | Group reply |
| `Ctrl-r` | Mark all as read |
| `?` | Show keybindings for current context |

## Browser Mode
| Key | Action |
|-----|--------|
| `h` | Go to parent folder |
| `l` | Select entry |
| `gg` | Top |
| `G` | Bottom |
