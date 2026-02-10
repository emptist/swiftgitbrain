# GitHub SSH vs HTTPS for GitBrainSwift

## Important Distinction

There are **two different things** when working with GitHub:

1. **Git Operations** - Clone, push, pull, fetch
2. **GitHub API Operations** - Create issues, get issues, add comments

## SSH vs HTTPS

### For Git Operations

**SSH URL** (Recommended):
```bash
git clone git@github.com:username/repo.git
```
- ✅ Uses SSH keys (no password needed)
- ✅ More secure
- ✅ No token storage required
- ✅ Works with SSH agents

**HTTPS URL**:
```bash
git clone https://github.com/username/repo.git
```
- ⚠️ Requires password or token
- ⚠️ Less secure (credentials in URL)
- ⚠️ Token stored in Git config

### For GitHub API Operations

**GitHub API ALWAYS requires a token**, regardless of Git URL:
```bash
# Creating issues, getting issues, etc.
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/repos/username/repo/issues
```

**SSH does NOT work for GitHub API!**

## Recommended Setup for GitBrainSwift

### 1. Use SSH for Git Operations

```bash
# Clone repository using SSH
git clone git@github.com:username/gitbrainswift.git
cd gitbrainswift

# Set remote to SSH
git remote set-url origin git@github.com:username/gitbrainswift.git

# Now push/pull uses SSH keys (no password!)
git push origin coder
git pull origin overseer
```

### 2. Use Token for GitHub API (Issues)

```bash
# Set token for API operations only
export GITHUB_TOKEN=your_github_token

# Token is ONLY used for GitHub API (issues, comments)
# NOT used for Git operations (push, pull)
```

## Complete Setup

### Step 1: Setup SSH Keys

```bash
# Generate SSH key (if not exists)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: https://github.com/settings/keys
```

### Step 2: Test SSH Connection

```bash
# Test SSH to GitHub
ssh -T git@github.com

# Should see: "Hi username! You've successfully authenticated..."
```

### Step 3: Create GitHub Token for API

```bash
# Go to: https://github.com/settings/tokens
# Generate new token (classic)
# Select scopes: repo, issues
# Copy token

# Set environment variable
export GITHUB_TOKEN=your_token_here
```

### Step 4: Use SSH for Git, Token for API

```bash
# Clone with SSH
git clone git@github.com:username/gitbrainswift.git
cd gitbrainswift

# Create worktrees
git worktree add coder-worktree -b coder
git worktree add overseer-worktree -b overseer

# Push/pull uses SSH (no password!)
cd coder-worktree
git push origin coder  # Uses SSH keys

# API operations use token
export GITHUB_TOKEN=your_token
./send_via_github_ssh.sh  # Uses token for API
```

## Why This Approach?

### SSH for Git:
- ✅ No passwords needed
- ✅ More secure
- ✅ Works with SSH agents
- ✅ No credential storage in Git config
- ✅ Automatic authentication

### Token for API:
- ✅ Required by GitHub API
- ✅ Fine-grained permissions
- ✅ Can be revoked anytime
- ✅ Only used for API, not Git

## Quick Reference

| Operation | Method | Authentication |
|-----------|--------|----------------|
| Clone | Git | SSH keys |
| Push | Git | SSH keys |
| Pull | Git | SSH keys |
| Create Issue | API | Token |
| Get Issues | API | Token |
| Add Comment | API | Token |
| Close Issue | API | Token |

## Troubleshooting

### SSH Issues

**Permission denied (publickey)**
```bash
# Check SSH key
ls -la ~/.ssh/id_ed25519*

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519

# Test SSH connection
ssh -vT git@github.com
```

**Connection refused**
```bash
# Check if SSH key is added to GitHub
# Go to: https://github.com/settings/keys

# Test SSH connection
ssh -T git@github.com
```

### Token Issues

**Unauthorized**
```bash
# Verify token is correct
echo $GITHUB_TOKEN

# Check token has correct scopes
# Go to: https://github.com/settings/tokens
# Ensure 'repo' and 'issues' are selected
```

**Rate limit exceeded**
```bash
# Check rate limit status
curl -H "Authorization: Bearer $GITHUB_TOKEN" \
  https://api.github.com/rate_limit

# Wait for reset (1 hour)
```

## Best Practices

1. **Use SSH for Git** - More secure, no passwords
2. **Use Token for API** - Required by GitHub API
3. **Store Token Securely** - Use environment variables, not in code
4. **Rotate Tokens Regularly** - Revoke old tokens, create new ones
5. **Use SSH Agent** - Avoid entering passphrase repeatedly
6. **Separate Concerns** - Git = SSH, API = Token

## Summary

- **Git Operations** → SSH (git@github.com)
- **GitHub API Operations** → Token (required)
- **SSH Keys** → For Git authentication
- **GitHub Token** → For API authentication
- **Both Required** → Complete GitBrainSwift setup

This is the most secure and convenient setup for GitBrainSwift collaboration!
