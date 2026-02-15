# Testing Plan: gitbrain init Command

**Date:** 2026-02-15
**Test Project:** aihome (game project)
**Participants:** Creator and Monitor
**Purpose:** Validate gitbrain init functionality

---

## Test Objective

**Verify that `gitbrain init` works correctly:**
1. Creates `.GitBrain/` hidden folder
2. Copies `AIDeveloperGuide.md` template
3. Creates database with correct naming
4. Runs migrations successfully

---

## Test Procedure

### Step 1: Create Test Project

```bash
# Create test directory
mkdir aihome
cd aihome

# Initialize git (optional but recommended)
git init
```

### Step 2: Run gitbrain init

```bash
# Run init command
gitbrain init
```

**Expected Output:**
```
✅ GitBrain initialized successfully!
   Created: .GitBrain/AIDeveloperGuide.md
   Database: gitbrain_aihome
   Migrations: Complete
```

### Step 3: Verify Structure

```bash
# Check hidden folder exists
ls -la

# Should show:
drwxr-xr-x   .GitBrain

# Check file exists
ls -la .GitBrain/

# Should show:
-rw-r--r--   AIDeveloperGuide.md

# Verify file content
head -20 .GitBrain/AIDeveloperGuide.md

# Should show the story of Creator and Monitor
```

### Step 4: Verify Database

```bash
# Check database exists
psql -U postgres -l | grep gitbrain_aihome

# Should show:
 gitbrain_aihome | postgres | UTF8     | ...

# Connect to database
psql -U postgres -d gitbrain_aihome

# Check tables exist
\dt

# Should show all message and knowledge tables
```

### Step 5: Test AI Workflow

**Creator AI:**
```bash
# Open in root folder
# Read .GitBrain/AIDeveloperGuide.md
# Understand role and responsibilities
# Start working
```

**Monitor AI:**
```bash
# Open in .GitBrain folder
# Read AIDeveloperGuide.md
# Understand role and responsibilities
# Start monitoring
```

### Step 6: Cleanup

```bash
# Delete test database
dropdb gitbrain_aihome

# Remove test directory
cd ..
rm -rf aihome
```

---

## What to Verify

### File System

- [ ] `.GitBrain/` folder created (hidden)
- [ ] `AIDeveloperGuide.md` exists inside
- [ ] File contains complete story and guide
- [ ] File is readable

### Database

- [ ] Database `gitbrain_aihome` created
- [ ] All tables exist (messages, knowledge, brain_states)
- [ ] Migrations ran successfully
- [ ] Database is accessible

### Content

- [ ] AIDeveloperGuide.md contains story section
- [ ] Keep-alive strategies documented
- [ ] Communication system explained
- [ ] CLI commands listed
- [ ] Best practices included

---

## Success Criteria

**The test passes if:**

1. ✅ `.GitBrain/` folder exists and is hidden
2. ✅ `AIDeveloperGuide.md` exists with complete content
3. ✅ Database `gitbrain_aihome` created successfully
4. ✅ All tables exist in database
5. ✅ AIs can read the guide and understand their roles
6. ✅ Cleanup removes all test artifacts

---

## Issues to Watch For

### Potential Problems

1. **Folder not hidden**
   - Check if folder name starts with `.`
   - Verify with `ls -la`

2. **Database name incorrect**
   - Should be `gitbrain_aihome`
   - Not `gitbrain_default` or other names

3. **File missing or incomplete**
   - Check file size
   - Verify content includes story section

4. **Migrations fail**
   - Check PostgreSQL is running
   - Verify connection parameters

5. **Permission issues**
   - Check write permissions in directory
   - Verify PostgreSQL user permissions

---

## Test Execution

**When:** After Monitor reads AIDeveloperGuide.md
**Who:** Creator and Monitor together
**Where:** Test directory `aihome/`

**Creator's Role:**
- Create test directory
- Run init command
- Verify file system structure
- Test AI workflow

**Monitor's Role:**
- Verify database creation
- Check table structure
- Review AIDeveloperGuide.md content
- Validate completeness

**Together:**
- Confirm all success criteria met
- Document any issues
- Clean up test artifacts

---

## After Testing

**Document Results:**
- What worked
- What didn't work
- Issues encountered
- Improvements needed

**Update Code:**
- Fix any bugs found
- Improve error messages
- Enhance user experience

**Update Documentation:**
- Add troubleshooting tips
- Clarify instructions
- Document edge cases

---

## Ready to Test

**This plan is ready for execution when:**
- ✅ Monitor has read AIDeveloperGuide.md
- ✅ Both AIs understand the test procedure
- ✅ PostgreSQL is running
- ✅ GitBrain CLI is built and available

**Let's test the init command together!**
