# Agent Development Rules & Documentation Standards - Flokower Project

## 📋 Overview

Document ini mengatur cara kerja AI agent dalam development process Flokower app, khususnya terkait:
1. Testing strategy dari sisi code
2. Dokumentasi updates
3. Problem-solution logging

---

## 🔧 TESTING PROTOCOL

### Priority Order of Operations

**ATURAN PENTING:** Selalu jalankan testing CODE DULU sebelum membuat/updating dokumentasi!

#### Step 1: Code Review (Manual Analysis)
```
Process:
1. Baca semua file code yang diubah/dibuat baru
2. Identify potential bugs atau edge cases
3. Check untuk logic errors
4. Validasi business logic alignment
5. Verify error handling completeness
```

**Checklist Code Review:**
- [ ] Semua validation rules implemented dengan benar?
- [ ] Error handling comprehensive (client + server)?
- [ ] Loading states mencegah duplicate actions?
- [ ] Atomic transactions untuk critical operations?
- [ ] Real-time sync listeners configured tepat?
- [ ] Security rules sesuai dengan intended access pattern?

#### Step 2: Unit Test Validation (Jika Ada)
```typescript
// Contoh test case yang harus valid:
test('Stock validation blocks insufficient orders', () {
  const product = getTestProduct(); // Needs 10 units
  const lowStockMaterial = getMaterialWith(5); // Only 5 available
  
  const canCreate = validateStockAvailability(product, [lowStockMaterial]);
  
  expect(canCreate).toBe(false); // Should be BLOCKED
});

test('Loading state prevents double completion', () => {
  const buttonState = createButtonState('idle');
  
  buttonState.click();
  expect(buttonState.isLoading).toBe(true); // Loading active
  
  buttonState.click(); // Second click attempt
  expect(buttonState.isClicked).toBe(false); // Ignored
});
```

#### Step 3: Integration Flow Testing
```javascript
// Test end-to-end scenarios manually:

Scenario: Complete order flow
1. Create product with ingredients
2. Add materials to inventory
3. Try to create order (should succeed if sufficient)
4. Complete order
5. Verify: Stock decreased correctly ✅
6. Cancel new order
7. Verify: Reserve released, stock unchanged ✅

Edge Cases to Test:
- ❌ Insufficient stock → Should block order creation
- ⚠️ Low stock warning → Should show alert but allow
- 🔄 Rapid clicks on same button → Should only process first
- 📱 Offline mode → Should queue operations locally
```

#### Step 4: Security Validation
```bash
# Manual Firestore rules testing:
1. Unauthenticated user → Should DENY all operations
2. Authenticated user → Should ALLOW read/write own data
3. Cross-user access → Should DENY accessing other users' data
4. Invalid data format → Should REJECT with clear error
5. Negative quantity update → Should BLOCK at database level
```

---

## 📝 DOCUMENTATION STANDARDS

### File Naming Convention

**Urutan penamaan menggunakan prefix numerik:**
```
001.xxx-name.md    ← First document in topic area
002.xxx-name.md    ← Second document
003.xxx-name.md
...
999.zzz-last.md    ← Last possible document
```

**Format lengkap:** `NNN.description-topic.md`

Contoh struktur folder:
```
docs/
├── prd-technical/
│   ├── 001.technical-prd.md
│   ├── 002.database-schema.md
│   └── 003.api-endpoints.md
├── problem-solution/
│   ├── 001.stock-race-condition-id.md (Indonesian)
│   ├── 001.stock-race-condition-en.md (English)
│   ├── 002.duplicate-click-prevention-id.md
│   └── 002.duplicate-click-prevention-en.md
└── business/
    ├── 001.business-model-analysis.md
    └── 002.kpi-tracking-framework.md
```

### Bilingual Documentation Rule

**KONDISI WAJIB:** Setiap dokumen di folder `problem-solution` HARUS ada 2 versi:
1. Bahasa Indonesia (`-id`)
2. Bahasa Inggris (`-en`)

**Exception:** Dokumen teknis seperti PRD bisa single language (Inggris).

**Contoh filename untuk problem-solution:**
```
Correct:
├── 001.concurrency-issue-id.md
└── 001.concurrency-issue-en.md

Wrong:
├── 001.concurrency-issue.md  ← Missing bilingual version!
```

### Update Policy when Concepts Change

**RULE 1: Jika ada perubahan konsep/architecture → UPDATE dokumen related**

**Workflow:**
```
1. Detect concept change in code OR discussion
2. Locate affected documentation files
3. Update relevant sections dengan detail perubahan
4. Update version history di header dokumen
5. Flag perubahan besar untuk review manual
```

**Contoh scenario:**
```
Original concept: Single-step stock deduction
New concept: Two-step (reserve → deduct)

Required document updates:
├── docs/prd-technical/001.technical-prd.md
│   └── Update: Database schema (add reservedQuantity field)
│   └── Update: Business logic rules (add reservation rule)
│
├── docs/business/002.business-logic.md
│   └── Update: Problem description (new benefit explained)
│
└── docs/problem-solution/00X.concurrency-id.md
    └── Update: Solution details (reservation mechanism)
```

**CHANGELOG FORMAT:**
```markdown
## 📝 Version History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0     | ...  | Initial creation | ... |
| 1.1     | YYYY-MM-DD | Updated reservation system implementation | Agent |
```

---

## 🐛 PROBLEM-SOLUTION LOGGING PROTOCOL

### When TO Log a Problem

**KRITERIA: ONLY log MAJOR problems, bukan trivial issues!**

#### Criteria untuk LOG (HARUS):
✅ **Complex business logic issues** yang require multi-layer solution  
✅ **Race conditions** atau concurrent access conflicts  
✅ **Data integrity risks** yang bisa cause corruption  
✅ **Security vulnerabilities** dengan impact tinggi  
✅ **Performance bottlenecks** dengan measurable degradation  
✅ **UX blockers** yang menyebabkan major user frustration  

#### DO NOT LOG (TRIVIAL):
❌ Typos atau formatting errors  
❌ Minor UI polish requests  
❌ Color scheme preferences  
❌ Cosmetic label changes  
❌ Edge cases with <1% probability  
❌ Future-proofing enhancements (not blocking current MVP)  

### Problem Logging Format

Setiap entry di `problem-solution` HARUS include:

#### Template Structure (Bahasa Indonesia):
```markdown
# NNN. Problem Title - ID

## 📖 Deskripsi Masalah
[Penjelasan jelas tentang apa masalahnya, siapa terdampak, kapan terjadi]

## 💥 Dampak Bisnis
- Dampak langsung ke operasi bisnis
- Financial impact estimation
- Customer satisfaction impact
- Data accuracy impact

## 🔍 Root Cause Analysis
[Mengapa masalah ini terjadi? Analisis teknis/bisnis]

## ✅ Solusi yang Diimplementasikan
[Detail solusi beserta justification decision]

## 📊 Metrics / KPI Impact
[Bagaimana mengukur success dari solusi?]

## 🔗 Related Files
- src/path/to/file.dart
- tests/test_file.test.dart

## 📝 Notes
[Any additional context, future considerations]
```

#### Template Structure (Bahasa Inggris):
```markdown
# NNN. Problem Title - EN

## 📖 Problem Description
[Clear explanation of what the problem is, who's impacted, when it occurs]

## 💥 Business Impact
- Direct operational impact
- Financial impact estimation
- Customer satisfaction impact
- Data accuracy impact

## 🔍 Root Cause Analysis
[Why does this problem occur? Technical/business analysis]

## ✅ Implemented Solution
[Detailed solution with decision justification]

## 📊 Metrics / KPI Impact
[How to measure solution success?]

## 🔗 Related Files
- src/path/to/file.dart
- tests/test_file.test.dart

## 📝 Notes
[Any additional context, future considerations]
```

---

## 🚀 DEPLOYMENT CHECKLIST FOR AGENT

### Before Committing Code Changes

```bash
# Run these checks automatically:

# 1. Code Quality
flutter analyze                    # No errors allowed
flutter format --set-exit-if-changed lib/  # Format check

# 2. Tests Passing
flutter test                       # All unit tests pass
integration_test/                  # Integration tests pass

# 3. Security Scan
firebase emulators:start          # Test security rules locally
firestore.rules: --rules_file firestore.rules  # Validate syntax

# 4. Documentation Updates
git status                         # Check if docs updated
diff docs/*.md                     # Review documentation changes
```

### If Bug Found During Development

**ACTION FLOW:**
```
1. IDENTIFY: Classify bug severity (critical/major/minor)
2. FIX: Implement fix dengan proper testing
3. LOG: IF critical OR complex → Write problem-solution doc
4. UPDATE DOCS: If concept changed → Update related documentation
5. TEST AGAIN: Verify fix doesn't break existing functionality
6. COMMIT: With detailed commit message including bug reference
```

**Example commit message:**
```
fix(transaction-completion): prevent duplicate deductions on rapid clicks

Resolved critical race condition where clicking complete button multiple times
caused stock to be deducted twice.

Implementation:
- Added loading state machine to disable button during processing
- Server-side validation to reject already-completed transactions
- Added audit logging for all completion attempts

Related: Problem-solution/002.duplicate-click-prevention.md

Closes: BUG-123
```

---

## 🎯 QUALITY ASSURANCE GATES

### Gate 1: Pre-Development
```
✓ Problem clearly defined with business impact
✓ Solution approach approved by team
✓ Test cases identified
✓ Documentation gaps mapped
```

### Gate 2: During Development
```
✓ Code follows established patterns
✓ Unit tests written for critical paths
✓ Integration points tested incrementally
✓ Progress documented in real-time
```

### Gate 3: Post-Development
```
✓ All tests passing (unit + integration)
✓ Security rules validated
✓ Documentation updated per requirements
✓ Problem logged if complexity warrants
✓ Performance benchmarks met
✓ Peer review completed
```

---

## 📞 ESCALATION PATH

### When Agent Should Stop & Ask Human:

1. **Critical Production Bugs** 
   - Any issue causing data loss or severe financial impact
   - Request: "Please review this critical issue immediately"

2. **Architecture Decisions**
   - Changing core design patterns mid-development
   - Request: "Need approval for architecture modification: [details]"

3. **Scope Creep**
   - Feature requests outside MVP scope
   - Request: "This enhancement exceeds MVP scope. Recommend moving to backlog?"

4. **Conflicting Requirements**
   - Business logic contradiction detected
   - Request: "Inconsistency found in requirements section X. Please clarify."

---

## 📚 EXAMPLE WORKFLOW

### Scenario: Fixing Race Condition Bug

```
STEP 1: Detection
------------------
User reports: "Stock becomes negative sometimes!"

Agent investigation:
- Review transaction logs
- Find pattern: Multiple completions on same product
- Identify root cause: No atomicity in stock deduction

STEP 2: Immediate Fix
---------------------
Implement Firestore runTransaction() wrapper
Add pre-completion validation check
Write failing unit test that reproduces bug

STEP 3: Testing Protocol
------------------------
Run flutter analyze ✓
Write unit test for atomic operation ✓
Integration test with concurrent updates ✓
All tests pass ✓

STEP 4: Document Update
-----------------------
Identify affected docs:
├── docs/prd-technical/001.technical-prd.md (update business rules)
└── docs/business/002.business-logic.md (add new constraint)

Update both files with:
- New technical requirement
- Example code snippet showing correct usage
- Version bump in changelog

STEP 5: Problem Logging
-----------------------
CREATE: docs/problem-solution/003.stock-race-condition-id.md
CREATE: docs/problem-solution/003.stock-race-condition-en.md

Content includes:
- Original symptom report
- Root cause analysis
- Solution architecture diagram
- Lessons learned
- Prevention checklist for future

STEP 6: Deployment
------------------
Git commit with detailed message
PR creation with all context
Human review → Approval → Merge → Deploy

RESULT: Bug fixed + knowledge preserved + team educated
```

---

## 🔑 KEY TAKEAWAYS

**Remember These Golden Rules:**

1. ✅ **CODE FIRST, DOCUMENT LATER** - Always validate code correctness before documenting
2. ✅ **BILINGUAL REQUIREMENT** - Problem-solution docs must have both versions
3. ✅ **LOG MAJOR ISSUES ONLY** - Not every bug needs documentation (use judgment!)
4. ✅ **UPDATE PROMPTLY** - Docs should reflect current reality, not historical artifacts
5. ✅ **TEST RIGOROUSLY** - If it's worth implementing, it's worth testing thoroughly
6. ✅ **ASK FOR HELP** - Don't hesitate when facing critical/confusing situations

---

*Last Updated: 2024-01-XX*  
*Maintained by: Development Team + AI Agents*  
*Version: 1.0*
