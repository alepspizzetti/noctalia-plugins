# WhatsApp Web

Open WhatsApp Web inside a Noctalia panel using `QtWebEngine`.

## Features

- Bar button to open the panel quickly
- Embedded WhatsApp Web session
- Persistent login session via a dedicated web profile
- Configurable panel position, width, height, and zoom

## Notes

- This plugin depends on `QtWebEngine` being available in the Noctalia runtime.
- Notifications, clipboard, audio, video, and local font access are granted to `web.whatsapp.com`.

## Development

Useful IPC command:

```bash
qs -c noctalia-shell ipc call plugin:whatsapp-web toggle
```
