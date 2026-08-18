# 📚 Flokower Documentation

Dokumentasi lengkap untuk proyek Flokower - Aplikasi manajemen inventaris dan penjualan untuk UMKM florist.

---

## 📂 Struktur Dokumentasi

```
docs/
├── prd-technical/          # Product Requirements & Technical Specifications
│   └── 001.technical-prd.md
│
├── business/               # Business Logic & Analysis  
│   └── 002.business-logic.md
│
├── problem-solution/       # Complex Issues & Solutions (Bilingual)
│   ├── id/                 # Bahasa Indonesia version
│   │   └── 001.stock-race-condition-id.md
│   └── en/                 # English version
│       └── 001.stock-race-condition-en.md
│
├── AGENT.md                # Development workflow & standards
├── CLAUDE.md               # Claude Code configuration
├── DESIGN.md               # Design system specifications
└── README.md               # This file
```

---

## 🎯 Dokumentasi Utama

### 1️⃣ Technical Product Requirements Document
**File:** `prd-technical/001.technical-prd.md`

**Coverage:**
- ✅ Core features specification
- ✅ Technology stack details
- ✅ Database schema definitions
- ✅ Firestore security rules
- ✅ Business logic implementation rules
- ✅ Design system specifications
- ✅ Navigation structure
- ✅ Testing strategy
- ✅ Performance requirements
- ✅ Deployment checklist

**Best For:** Developers, architects, technical reviewers

---

### 2️⃣ Business Logic & Analysis
**File:** `business/002.business-logic.md`

**Coverage:**
- ✅ Business model overview
- ✅ User persona analysis
- ✅ 6 major business problems identified
- ✅ Detailed root cause analysis
- ✅ Comprehensive solutions with examples
- ✅ Metrics & KPI definitions
- ✅ Growth scenarios (Phases 2-4)
- ✅ Quality assurance framework

**Best For:** Business stakeholders, product managers, project owners

---

### 3️⃣ Problem-Solution Repository
**Location:** `problem-solution/` folder (bilingual)

#### Current Entries:
**Indonesian Version:**
- **#001 Stock Race Condition** (ID): `id/001.stock-race-condition-id.md`

**English Version:**
- **#001 Stock Race Condition** (EN): `en/001.stock-race-condition-en.md`

**Content Structure:**
- Problem description (scenario timeline)
- Business impact quantification
- Root cause analysis (technical + process)
- Layered solution architecture
- Implementation details with code examples
- Metrics/KPI tracking methods
- Related files reference
- Lessons learned & future enhancements

**When Created:** Only for MAJOR complex issues, NOT trivial bugs

---

### 4️⃣ Agent Development Rules
**File:** `AGENT.md`

**Covers:**
- ✅ Testing protocol (code first, docs later)
- ✅ Documentation naming conventions
- ✅ Bilingual requirement explanation
- ✅ Update policy when concepts change
- ✅ When to log problems vs ignore trivial issues
- ✅ Quality assurance gates
- ✅ Escalation path for critical situations
- ✅ Complete example workflow

**Purpose:** Guide AI agents and developers on proper development workflow

---

### 5️⃣ Claude Code Configuration
**File:** `CLAUDE.md`

**Covers:**
- ✅ Project context & overview
- ✅ Development guidelines
- ✅ Coding standards (Flutter patterns)
- ✅ State management best practices
- ✅ Testing requirements
- ✅ Bug handling protocol
- ✅ Useful document links
- ✅ Quick checklists

**Purpose:** Configuration guide for Claude.ai assistant

---

### 6️⃣ Design System Specifications
**File:** `DESIGN.md`

**Covers:**
- ✅ Color palette (Light/Dark mode)
- ✅ Typography scale (Inter font family)
- ✅ Spacing system (8px grid)
- ✅ Border radius guidelines
- ✅ Component styles (Cards, Buttons, Inputs)
- ✅ Layout patterns (Bento Grid, Bottom Nav)
- ✅ Animation timings & easing
- ✅ Theme configuration (Flutter ThemeData)
- ✅ Platform adaptations
- ✅ Accessibility requirements

**Purpose:** UI/UX design tokens and component library

---

## 🔄 Documentation Workflow

### Standard Process:
```
1. Code Changes Made
   ↓
2. Run Tests (Must Pass!)
   ↓
3. Update Docs if Concepts Changed
   ↓
4. If Major Issue → Log in Problem-Solution (Bilingual)
   ├─ Create ID version in problem-solution/id/
   └─ Create EN version in problem-solution/en/
   ↓
5. Commit with Clear Message
```

### File Naming Convention:
- **Sequential numbers:** `001.xxx`, `002.xxx`, etc.
- **Problem-solution MUST be bilingual:** Separate `-id` and `-en` folders
- **Topic clear:** Description indicates content area

### Example Files:
```
Correct:
├── 001.technical-prd.md           ← Single language OK
├── problem-solution/id/
│   └── 001.stock-issue-id.md     ← Indonesian version
└── problem-solution/en/
    └── 001.stock-issue-en.md      ← English version

Incorrect:
├── stock-issue.md                 ← Missing bilingual pair!
└── bug-fix-document.md            ← Wrong naming format
```

---

## 📋 Quick Reference

### For Developers:
Start here → `prd-technical/001.technical-prd.md`

### For Product Owners:
Start here → `business/002.business-logic.md`

### For Troubleshooting:
- Check Indonesian: `problem-solution/id/`
- Check English: `problem-solution/en/`

### For Team Workflow:
Start here → `AGENT.md`

### For Claude Assistant:
Start here → `CLAUDE.md`

### For UI/UX Design:
Start here → `DESIGN.md`

---

## 🆕 Adding New Documentation

### Step-by-Step:

1. **Identify document type:**
   - Technical spec → `prd-technical/`
   - Business logic → `business/`
   - Complex issue → `problem-solution/id/` AND `problem-solution/en/`

2. **Assign next sequential number** based on existing files

3. **Create filename** with format:
   ```
   NNN.descriptive-name.md
   ```

4. **Write content** following template structure from this README

5. **If problem-solution:** Create BOTH versions in separate folders:
   ```bash
   # Create Indonesian version
   echo "..." > problem-solution/id/NNN.issue-id.md
   
   # Create English version  
   echo "..." > problem-solution/en/NNN.issue-en.md
   ```

6. **Update this index** with new entry

7. **Tag relevant team members** for review

---

## 🔍 Search Tips

### Using VS Code Search:
```
Global search patterns:
- "stock reservation" → Find all related documents
- "race condition" → Trace problem history
- "atomic transaction" → Find implementation details
```

### GitHub Web Search:
```
Use repository search with keywords:
- In filename: race*condition*
- In content: "negative stock" AND prevention
```

---

## 📞 Contact & Support

### Questions About Documentation:
- Check `AGENT.md` for formatting guidelines
- Review existing documents for templates/examples
- Ask team lead for clarification

### Reporting Documentation Issues:
- Create new issue with label "documentation"
- Describe what's missing or unclear
- Suggest improvements with specific references

---

## 📝 Version Tracking

### Document Updates:
All documents include version history table at bottom:
```markdown
## 📝 Version History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0     | ...  | Initial creation | ... |
| 1.1     | ...  | Updated content | ... |
```

### Changelog Priority:
1. Critical bugs fixed
2. Feature additions/modifications
3. Architecture changes
4. Security updates

---

## ✨ Contributing Guidelines

### Do:
✅ Write clear, concise explanations  
✅ Include code examples when helpful  
✅ Update both languages simultaneously for problem-solution  
✅ Link to related documents  
✅ Use consistent formatting  

### Don't:
❌ Make undocumented assumptions  
❌ Leave broken links  
❌ Skip testing before documenting  
❌ Forget to update version history  
❌ Mix languages in same document (except bilingual pair)  

---

*Last Updated: 2024-01-XX*  
*Maintained by: Flokower Development Team*  
*Version: 1.0*
