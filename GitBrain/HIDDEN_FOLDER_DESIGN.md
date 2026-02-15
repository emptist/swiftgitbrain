# GitBrain Folder Structure: Hidden Folder Design

**Date:** 2026-02-15
**Design Decision:** `.GitBrain` folder is hidden
**Author:** Creator

---

## The Hidden Folder Design

### Why Hidden Folder?

**The `.GitBrain` folder starts with a dot (`.`), making it hidden.**

**Benefits:**
1. ✅ **Clean Project View** - Doesn't clutter the user's project
2. ✅ **Standard Convention** - Follows Unix/Linux/macOS conventions
3. ✅ **Separation of Concerns** - GitBrain infrastructure separate from project files
4. ✅ **Professional** - Looks like other tool folders (`.git`, `.github`, etc.)

### Standard Examples

**Other hidden folders in projects:**
- `.git/` - Git repository data
- `.github/` - GitHub workflows and configs
- `.vscode/` - VS Code settings
- `.idea/` - IntelliJ IDEA settings
- `.env` - Environment variables
- `.gitignore` - Git ignore rules

**GitBrain follows this pattern:**
- `.GitBrain/` - GitBrain AI collaboration infrastructure

---

## The Structure

### What `gitbrain init` Creates

```
customer-project/
├── .GitBrain/              ← Hidden folder
│   └── AIDeveloperGuide.md ← The ONLY file
├── src/
├── tests/
├── README.md
└── ... (customer's project files)
```

### What's Inside `.GitBrain/`

**Currently:**
- `AIDeveloperGuide.md` - Complete guide for AIs

**Future (optional):**
- `config.yml` - GitBrain configuration
- `brain_states/` - Local brain state cache
- `knowledge/` - Local knowledge cache
- `logs/` - Daemon logs

---

## How AIs Access It

### Creator AI

**Working Directory:** Project root folder
**Reads:** `.GitBrain/AIDeveloperGuide.md`
**Role:** Implements features

```bash
# Creator AI starts in root folder
cd /path/to/customer-project

# Reads the guide
cat .GitBrain/AIDeveloperGuide.md
```

### Monitor AI

**Working Directory:** `.GitBrain` folder (hidden)
**Reads:** `AIDeveloperGuide.md` (in current directory)
**Role:** Reviews and coordinates

```bash
# Monitor AI starts in .GitBrain folder
cd /path/to/customer-project/.GitBrain

# Reads the guide
cat AIDeveloperGuide.md
```

---

## The init Command

### What `gitbrain init` Does

**Step 1: Detect Project Name**
```bash
# From current directory name
project_name=$(basename $(pwd))

# Or from package.json, Cargo.toml, etc.
```

**Step 2: Create Hidden Folder**
```bash
mkdir -p .GitBrain
```

**Step 3: Copy AIDeveloperGuide.md**
```bash
# From template
cp /usr/local/share/gitbrain/templates/AIDeveloperGuide.md .GitBrain/
```

**Step 4: Create Database**
```bash
# Database name: gitbrain_<project_name>
createdb gitbrain_${project_name}
```

**Step 5: Run Migrations**
```bash
gitbrain migrate
```

---

## The User Experience

### Customer Perspective

**What the customer sees:**
```
customer-project/
├── src/
├── tests/
└── README.md
```

**What's actually there:**
```
customer-project/
├── .GitBrain/              ← Hidden, but present
│   └── AIDeveloperGuide.md
├── .git/                   ← Also hidden
├── src/
├── tests/
└── README.md
```

**To see hidden folders:**
```bash
ls -la

# Output:
drwxr-xr-x   .GitBrain
drwxr-xr-x   .git
drwxr-xr-x   src
drwxr-xr-x   tests
-rw-r--r--   README.md
```

---

## Why This Matters

### Clean Separation

**GitBrain infrastructure:**
- Hidden from normal view
- Doesn't interfere with project
- Professional appearance
- Follows conventions

**Customer project:**
- Visible and accessible
- Uncluttered by GitBrain files
- Focus on their work
- Standard project structure

### AI Collaboration

**Both AIs:**
- Know where to find the guide
- Understand the hidden folder structure
- Can access GitBrain infrastructure
- Work together seamlessly

**The guide:**
- Tells them about keep-alive
- Explains communication
- Documents collaboration
- Provides all instructions

---

## Implementation in init Command

### Current Status

**Need to update `gitbrain init` to:**
1. Create `.GitBrain` folder (hidden)
2. Copy `AIDeveloperGuide.md` template
3. Create database with correct name
4. Run migrations

### Code Example

```swift
// In init command
func initializeGitBrain() async throws {
    // 1. Create hidden folder
    let gitbrainDir = ".GitBrain"
    try FileManager.default.createDirectory(atPath: gitbrainDir, withIntermediateDirectories: true)
    
    // 2. Copy AIDeveloperGuide.md template
    let templatePath = "/usr/local/share/gitbrain/templates/AIDeveloperGuide.md"
    let destinationPath = "\(gitbrainDir)/AIDeveloperGuide.md"
    try FileManager.default.copyItem(atPath: templatePath, toPath: destinationPath)
    
    // 3. Create database
    let projectName = FileManager.default.currentDirectoryPath.lastPathComponent
    let dbName = "gitbrain_\(projectName.lowercased().replacingOccurrences(of: "-", with: "_"))"
    try await createDatabase(name: dbName)
    
    // 4. Run migrations
    try await runMigrations()
    
    print("✅ GitBrain initialized successfully!")
    print("   Created: .GitBrain/AIDeveloperGuide.md")
    print("   Database: \(dbName)")
}
```

---

## The Complete Picture

### Customer Workflow

```bash
# 1. Create project
mkdir my-awesome-project
cd my-awesome-project

# 2. Initialize GitBrain
gitbrain init

# Output:
# ✅ GitBrain initialized successfully!
#    Created: .GitBrain/AIDeveloperGuide.md
#    Database: gitbrain_my_awesome_project

# 3. Open in Trae editor (two instances)
# Instance 1: Root folder (Creator AI)
# Instance 2: .GitBrain folder (Monitor AI)

# 4. AIs read the guide and start working
```

### AI Workflow

**Creator AI:**
1. Starts in root folder
2. Reads `.GitBrain/AIDeveloperGuide.md`
3. Understands role and responsibilities
4. Starts implementing features
5. Communicates with Monitor via GitBrain

**Monitor AI:**
1. Starts in `.GitBrain` folder
2. Reads `AIDeveloperGuide.md` (in current dir)
3. Understands role and responsibilities
4. Starts reviewing and coordinating
5. Communicates with Creator via GitBrain

---

## Summary

**The `.GitBrain` folder is hidden because:**
- ✅ It's a standard convention
- ✅ Keeps projects clean
- ✅ Professional appearance
- ✅ Separates infrastructure from project

**The `AIDeveloperGuide.md` is the ONLY file because:**
- ✅ Contains all instructions
- ✅ Self-contained guide
- ✅ Easy to maintain
- ✅ Simple for AIs to read

**This is the correct design for GitBrain.**
