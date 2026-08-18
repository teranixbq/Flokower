# 🤖 Flokower - Claude Code Configuration

## 📋 Overview

This document provides configuration instructions for Claude Code (claude.ai) when working on the Flokower Flutter mobile app project.

---

## 🎯 Project Context

**Flokower** is a mobile inventory and sales management system for UMKM florists, built with Flutter and Firebase.

### Key Features:
- Material & Product CRUD management
- Soft stock reservation system (in_progress → completed)
- Custom ingredient override per transaction
- Real-time multi-user synchronization
- Bento grid dashboard design
- Excel export functionality

---

## 🔧 Development Guidelines

### When Responding to Requests:

#### 1. **Understand the Business First**
Always reference `docs/business/002.business-logic.md` before implementing features. This document contains:
- 6 major business problems identified
- Root cause analysis for each problem
- Layered solution architecture
- Metrics/KPI frameworks

**Example:**
If user requests stock deduction feature:
→ Reference Problem #3 (Race Conditions) in business logic doc
→ Implement 4-layer protection system as documented
→ Include real-time sync + atomic transactions

#### 2. **Follow Technical Specifications**
Reference `docs/prd-technical/001.technical-prd.md` for:
- Database schema definitions
- Security rules implementation
- Business logic rules
- Design system tokens

#### 3. **Test Before Documenting**
Per `./AGENT.md`:
```
Priority Order:
1. Write test cases FIRST
2. Implement feature
3. Verify tests pass
4. Update docs only if concepts changed
```

#### 4. **Problem-Solution Documentation**
When encountering complex issues:
- Log ONLY MAJOR problems (not trivial bugs)
- Create bilingual files: `-id.md` and `-en.md`
- Follow template in `docs/problem-solution/id/001.stock-race-condition-id.md`
- Number sequentially starting from 003 (after existing 001, 002)

---

## 🏗️ Project Structure

```
flokower/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── widgets/
│   │   ├── utils/
│   │   └── services/
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── inventory/
│   │   ├── transactions/
│   │   └── reports/
│   └── shared/
├── docs/
│   ├── prd-technical/
│   │   └── 001.technical-prd.md
│   ├── business/
│   │   └── 002.business-logic.md
│   ├── problem-solution/
│   │   ├── id/
│   │   │   └── 001.stock-race-condition-id.md
│   │   └── en/
│   │       └── 001.stock-race-condition-en.md
│   ├── AGENT.md
│   ├── CLAUDE.md (this file)
│   ├── DESIGN.md
│   └── README.md
└── test/
```

---

## 📝 Coding Standards

### File Naming:
- Use descriptive names with context
- Separate concerns into small files
- Group related files in same folder

### Component Structure:
```dart
// Feature file organization:
lib/features/{feature-name}/
├── data/
│   ├── models/{model_name}.dart
│   └── repositories/{repository_name}.dart
├── presentation/
│   ├── providers/{provider_name}.dart
│   ├── screens/{screen_name}.dart
│   └── widgets/
└── {feature-name}.dart (exports)
```

### State Management:
Use Riverpod pattern:
```dart
// Provider definition
final materialRepositoryProvider = Provider((ref) {
  return MaterialRepository(firestore);
});

// Usage in screen
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(materialsProvider);
    // ...
  }
}
```

### Business Logic Implementation:
Follow these patterns:

#### Stock Validation:
```typescript
// Pattern from technical PRD
function canCreateOrder(product, availableStock): boolean {
  for (ingredient of product.ingredients) {
    const material = getMaterial(ingredient.materialId);
    const available = material.currentQuantity - material.reservedQuantity;
    
    if (available < ingredient.quantityNeeded) {
      return false; // Block creation
    }
  }
  return true;
}
```

#### Atomic Transaction:
```typescript
// Pattern for completion flow
async function completeTransaction(transactionId: string) {
  await firestore.runTransaction(async (txn) => {
    // All-or-nothing updates here
    // Step 1: Validate current state
    // Step 2: Perform updates atomically
    // Step 3: Return success or throw error
  });
}
```

#### Loading State Protection:
```dart
// Prevent duplicate clicks
class CompleteButton extends StatefulWidget {
  @override
  _CompleteButtonState createState() => _CompleteButtonState();
}

class _CompleteButtonState extends State<CompleteButton> {
  bool _isLoading = false;
  
  Future<void> _handleComplete() async {
    if (_isLoading) return; // Ignore rapid clicks
    
    setState(() => _isLoading = true);
    
    try {
      await transactionService.complete(widget.transaction.id);
      _showSuccessMessage();
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleComplete,
      child: _isLoading 
        ? CircularProgressIndicator() 
        : Text('Complete'),
    );
  }
}
```

---

## 🎨 Design System Tokens

Refer to `docs/DESIGN.md` for UI specifications:

### Colors (Light Mode):
```dart
Background: #FFFFFF
Surface/Card: #F8F8F8
Primary Text: #000000
Secondary Text: #666666
Borders: #E0E0E0

Status Colors:
  Success: #00C853
  Warning: #FFA000
  Error: #FF5252
```

### Typography:
```dart
Headlines:
  Large: SemiBold 32px
  Medium: Medium 24px
  
Body:
  Large: Regular 16px
  Medium: Regular 14px
```

### Spacing:
```dart
XS: 4px  SM: 8px  MD: 16px  LG: 24px  XL: 32px
```

---

## 🧪 Testing Requirements

### Always Test Before Committing:
```bash
# Run in project root
flutter analyze
flutter test
```

### Test Coverage Priority:
1. **Critical paths first** (stock validation, completion flow)
2. **Business logic functions** (calculations, validations)
3. **UI components** (forms, buttons, lists)
4. **Integration tests** (end-to-end workflows)

### Example Test Case:
```dart
// test/unit/stock_validation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flokower/core/utils/validators.dart';

void main() {
  group('Stock Validation', () {
    test('blocks order when insufficient stock', () {
      final product = Product(
        ingredients: [
          MaterialIngredient(materialId: 'm1', quantityNeeded: 10)
        ]
      );
      
      final materials = {
        'm1': Material(quantity: 5, reservedQuantity: 0)
      };
      
      final result = canCreateOrder(product, materials);
      
      expect(result, isFalse);
    });
    
    test('allows order when sufficient stock', () {
      final product = Product(
        ingredients: [
          MaterialIngredient(materialId: 'm1', quantityNeeded: 5)
        ]
      );
      
      final materials = {
        'm1': Material(quantity: 10, reservedQuantity: 0)
      };
      
      final result = canCreateOrder(product, materials);
      
      expect(result, isTrue);
    });
  });
}
```

---

## 🐛 Bug Handling Protocol

### If You Discover a Bug:

1. **Classify Severity:**
   - CRITICAL: Data loss, financial impact
   - MAJOR: Major feature broken
   - MINOR: Cosmetic, workaround exists

2. **Fix Immediately:**
   - Write failing test first
   - Implement fix
   - Verify all tests pass

3. **Log Only Major Issues:**
   ```
   If CRITICAL or MAJOR:
   → Create new problem-solution entry
   → Use numbering after last entry (currently 003+)
   → Create both -id.md and -en.md versions
   → Update AGENT.md if process needs change
   ```

4. **Update Related Docs:**
   - If business logic changed → Update business-logic.md
   - If technical spec changed → Update technical-prd.md
   - Add version history entry in affected documents

---

## 📞 When to Ask Questions

Ask human developer when facing:
- ✋ Critical production bugs with data loss risk
- ✋ Architecture decisions requiring trade-off choices
- ✋ Scope creep beyond MVP requirements
- ✋ Conflicting requirements or unclear specifications

---

## 🔗 Useful Document Links

- **[Technical PRD](../prd-technical/001.technical-prd.md)** - Full specs
- **[Business Logic](../business/002.business-logic.md)** - Problem analysis
- **[Agent Rules](../AGENT.md)** - Workflow guidelines
- **[Design System](../DESIGN.md)** - UI tokens
- **[Problem #001](../problem-solution/id/001.stock-race-condition-id.md)** - Solution example

---

## ✅ Quick Checklist

Before implementing any feature:
- [ ] Read relevant business logic doc
- [ ] Check technical PRD for schema/rules
- [ ] Review existing code patterns
- [ ] Write test cases
- [ ] Implement feature
- [ ] Run all tests
- [ ] Update docs if needed
- [ ] Log major problems (bilingual)

---

*Last Updated: 2024-01-XX*  
*Maintained by: Flokower Development Team*  
*Version: 1.0*
