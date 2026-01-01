# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in EDAF, please report it responsibly:

### How to Report

**For security issues, please do NOT open a public GitHub issue.**

Instead, please report security vulnerabilities by:

1. **Email**: [Create a private security advisory on GitHub](https://github.com/Tsuchiya2/evaluator-driven-agent-flow/security/advisories/new)
2. **Private Report**: Use GitHub's private vulnerability reporting feature

### What to Include

Please include the following information in your report:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** of the vulnerability
- **Suggested fix** (if you have one)
- **Your contact information** for follow-up

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 7 days
- **Status updates**: Every 7 days until resolved
- **Fix timeline**: Depends on severity
  - Critical: 1-7 days
  - High: 7-14 days
  - Medium: 14-30 days
  - Low: 30-90 days

## Security Considerations

### EDAF Usage

EDAF is designed to evaluate and generate code. When using EDAF:

⚠️ **Review generated code** before deploying to production
⚠️ **Run in sandboxed environments** during evaluation
⚠️ **Do not commit secrets** in configuration files
⚠️ **Validate inputs** from external sources

### Configuration Files

- `.claude/edaf-config.yml` - Does not store credentials
- `.claude/CLAUDE.md` - Does not store sensitive data
- `.claude/settings.json` - May contain local paths (not secrets)

### Sound Files

- Sound files in `.claude/sounds/` are provided for notifications
- These files are safe and licensed (see README.md for attribution)

### Script Execution

EDAF includes bash scripts:
- `.claude/scripts/notification.sh` - Plays notification sounds
- `.claude/scripts/verify-ui.sh` - Validates UI verification

**Security notes:**
- Scripts do not access network
- Scripts do not modify code
- Scripts only read/validate local files

### Claude in Chrome

If using Claude in Chrome for UI verification:

⚠️ **Use only in development environments**
⚠️ **Do not expose dev server publicly**
⚠️ **Use test credentials** (not production credentials)
⚠️ **Verify extension is official** (from Chrome Web Store)

## Best Practices

### For Users

1. **Clone from official repository** only
2. **Review code** before running
3. **Use in development environments** first
4. **Keep Claude Code updated**
5. **Do not store secrets** in EDAF configuration

### For Contributors

1. **Do not introduce dependencies** with known vulnerabilities
2. **Validate all user inputs** in workers/evaluators
3. **Avoid shell injection** in bash scripts
4. **Document security implications** of changes
5. **Test in isolated environments**

## Known Limitations

EDAF is designed for development environments and has these limitations:

- **Not designed for untrusted code execution** - Use in trusted development environments
- **No built-in sandboxing** - Relies on Claude Code's execution environment
- **Local file system access** - Workers/evaluators read local files
- **Script execution** - Bash scripts execute with user permissions

## Disclosure Policy

When a security vulnerability is confirmed:

1. **Fix developed** and tested privately
2. **Security advisory** published on GitHub
3. **Patch released** as new version
4. **Users notified** via GitHub release notes
5. **Credit given** to reporter (if desired)

## Security Updates

Subscribe to security advisories:
- **GitHub Watch** → Custom → Security alerts
- **GitHub Releases** for security patches

## Contact

For security concerns:
- Use GitHub Security Advisories (preferred)
- Open a private vulnerability report
- Do NOT use public issues for security vulnerabilities

---

**Thank you for helping keep EDAF secure!** 🔒
