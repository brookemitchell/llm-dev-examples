# Accessibility Audit

## Purpose

Identify and fix accessibility issues to ensure the application is usable by everyone, including people with disabilities. Accessibility is not optional—it's a legal requirement in many jurisdictions and a moral obligation.

**Context**: ~15% of the world's population has some form of disability. If your app isn't accessible, you're excluding millions of potential users. Beyond the moral case, there's a business case (larger audience) and legal case (ADA/Section 508 compliance). Good accessibility also improves UX for everyone.

## Critical Principles

1. **Start with semantic HTML**

   - Use `<button>` for buttons, not `<div onClick>`
   - Use `<a>` for links, not `<span onClick>`
   - Use proper heading hierarchy (`<h1>` → `<h2>` → `<h3>`)
   - **WHY**: Screen readers depend on semantic HTML

2. **Keyboard navigation is not optional**

   - Every interactive element must be keyboard accessible
   - Tab order must be logical
   - Focus indicators must be visible
   - **WHY**: Many users can't use a mouse

3. **Don't rely on color alone**

   - Use icons + text, not just color
   - Ensure sufficient color contrast (4.5:1 minimum)
   - **WHY**: Colorblind users can't distinguish colors

4. **Test with actual assistive technology**
   - Use a screen reader (VoiceOver, NVDA)
   - Navigate with keyboard only
   - Test with browser zoom at 200%
   - **WHY**: Automated tools catch ~30-40% of issues

## Steps

### 1. Automated Scan (Quick First Pass)

**Run automated tools to catch obvious issues**:

```bash
# Install tools
npm install -D @axe-core/cli lighthouse

# Run axe accessibility scanner
npx axe http://localhost:3000 --stdout

# Run Lighthouse accessibility audit
npx lighthouse http://localhost:3000 --only-categories=accessibility --output=html --output-path=./accessibility-report.html
```

**Review automated findings**:

- Critical violations (must fix)
- Warnings (should investigate)
- Best practices (consider fixing)

**WHY automated first**: Catches low-hanging fruit quickly

### 2. Manual Keyboard Navigation Test

**Navigate the entire app using ONLY keyboard**:

```markdown
Test checklist:

- [ ] Can reach all interactive elements with Tab key
- [ ] Tab order is logical (top to bottom, left to right)
- [ ] Can activate buttons/links with Enter/Space
- [ ] Can close modals/dialogs with Escape
- [ ] Focus indicators are clearly visible
- [ ] Can navigate form fields with Tab
- [ ] Can select radio/checkbox with Space
- [ ] Can navigate dropdown menus with arrow keys
- [ ] No keyboard traps (can Tab out of everything)
- [ ] Skip-to-content link works
```

**Common keyboard issues to fix**:

❌ **Div buttons (not keyboard accessible)**:

```jsx
// Bad: Not keyboard accessible
<div onClick={() => submit()}>Submit</div>
```

✅ **Real buttons (keyboard accessible)**:

```jsx
// Good: Keyboard accessible
<button onClick={() => submit()}>Submit</button>
```

❌ **Missing focus indicators**:

```css
/* Bad: Removing focus outline */
button:focus {
  outline: none; /* Never do this! */
}
```

✅ **Visible focus indicators**:

```css
/* Good: Custom focus style */
button:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* Even better: Use :focus-visible (only shows on keyboard) */
button:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}
```

### 3. Screen Reader Test

**Test with screen reader**:

- **Mac**: VoiceOver (Cmd+F5)
- **Windows**: NVDA (free) or JAWS
- **Mobile**: VoiceOver (iOS) or TalkBack (Android)

**Navigate and verify**:

```markdown
Screen reader checklist:

- [ ] All images have descriptive alt text
- [ ] All form fields have labels
- [ ] Error messages are announced
- [ ] Page title describes current page
- [ ] Landmark regions are defined (header, nav, main, footer)
- [ ] Heading hierarchy is logical
- [ ] Button/link purpose is clear from text
- [ ] Dynamic content changes are announced
- [ ] Loading states are announced
- [ ] Success/error messages are announced
```

**Common screen reader issues**:

❌ **Missing alt text**:

```jsx
// Bad: No alt text
<img src="profile.jpg" />
```

✅ **Descriptive alt text**:

```jsx
// Good: Descriptive alt
<img src="profile.jpg" alt="User profile photo" />

// For decorative images (not meaningful)
<img src="decorative-border.svg" alt="" role="presentation" />
```

❌ **Missing form labels**:

```jsx
// Bad: Placeholder is not a label
<input type="email" placeholder="Email" />
```

✅ **Proper form labels**:

```jsx
// Good: Explicit label
<label htmlFor="email">Email</label>
<input type="email" id="email" />

// Or implicit label
<label>
  Email
  <input type="email" />
</label>
```

❌ **Unclear button text**:

```jsx
// Bad: Screen reader says "button, click here"
<button>Click here</button>
```

✅ **Descriptive button text**:

```jsx
// Good: Screen reader says "button, submit registration form"
<button>Submit registration form</button>

// Or use aria-label for icon buttons
<button aria-label="Close dialog">
  <CloseIcon />
</button>
```

### 4. Color Contrast Check

**Use tools to check color contrast**:

- Browser DevTools (Chrome: Inspect → Accessibility pane)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)

**WCAG Requirements**:

- **AA (minimum)**: 4.5:1 for normal text, 3:1 for large text (18pt+)
- **AAA (enhanced)**: 7:1 for normal text, 4.5:1 for large text

❌ **Poor contrast**:

```css
/* Bad: 2.8:1 contrast (fails WCAG) */
.text {
  color: #999999; /* Light gray */
  background: #ffffff; /* White */
}
```

✅ **Sufficient contrast**:

```css
/* Good: 7:1 contrast (passes WCAG AAA) */
.text {
  color: #595959; /* Dark gray */
  background: #ffffff; /* White */
}
```

**Don't rely on color alone**:

```jsx
// ❌ Bad: Only color indicates error
<input style={{ borderColor: 'red' }} />

// ✅ Good: Icon + text + color
<div>
  <input aria-invalid="true" aria-describedby="email-error" />
  <span id="email-error" role="alert">
    <ErrorIcon /> Error: Email is required
  </span>
</div>
```

### 5. ARIA Usage Review

**Check ARIA attributes**:

⚠️ **First rule of ARIA: Don't use ARIA** (use semantic HTML instead)

❌ **Unnecessary ARIA**:

```jsx
// Bad: ARIA not needed with semantic HTML
<div role="button" tabIndex="0" onClick={...}>Click me</div>
```

✅ **Semantic HTML (no ARIA needed)**:

```jsx
// Good: Button is already a button
<button onClick={...}>Click me</button>
```

**When ARIA is needed**:

```jsx
// ✅ Good: ARIA for custom widgets
<div
  role="dialog"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
  aria-modal="true"
>
  <h2 id="dialog-title">Confirm deletion</h2>
  <p id="dialog-description">Are you sure you want to delete this item?</p>
  <button>Cancel</button>
  <button>Delete</button>
</div>

// ✅ Good: Live region for dynamic updates
<div aria-live="polite" aria-atomic="true" role="status">
  {message && <p>{message}</p>}
</div>

// ✅ Good: Progress indicator
<div
  role="progressbar"
  aria-valuenow={progress}
  aria-valuemin="0"
  aria-valuemax="100"
  aria-label="Upload progress"
>
  {progress}%
</div>
```

### 6. Mobile & Responsive Accessibility

```markdown
Mobile accessibility checklist:

- [ ] Touch targets are at least 44x44px
- [ ] Works with screen zoom at 200%
- [ ] No horizontal scrolling at 320px width
- [ ] Touch gestures have keyboard alternatives
- [ ] Works in portrait and landscape
```

❌ **Touch targets too small**:

```css
/* Bad: 24px button (hard to tap) */
.icon-button {
  width: 24px;
  height: 24px;
}
```

✅ **Proper touch targets**:

```css
/* Good: 44px+ touch target */
.icon-button {
  width: 44px;
  height: 44px;
  /* Icon can be smaller, padding makes target bigger */
}
```

## Common Fixes

### Fix 1: Add Skip Navigation Link

```jsx
// Add at top of page (visible on focus)
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

<main id="main-content">
  {/* Main content */}
</main>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 9999;
}

.skip-link:focus {
  top: 0;
}
```

### Fix 2: Accessible Modal/Dialog

```jsx
import { useEffect, useRef } from "react";

function Modal({ isOpen, onClose, title, children }) {
  const modalRef = useRef();
  const previousFocusRef = useRef();

  useEffect(() => {
    if (isOpen) {
      // Save previous focus
      previousFocusRef.current = document.activeElement;

      // Focus modal
      modalRef.current?.focus();

      // Trap focus inside modal
      const focusableElements = modalRef.current.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );

      // Handle Escape key
      const handleEscape = (e) => {
        if (e.key === "Escape") onClose();
      };

      document.addEventListener("keydown", handleEscape);

      return () => {
        document.removeEventListener("keydown", handleEscape);
        // Restore focus
        previousFocusRef.current?.focus();
      };
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      className="modal-overlay"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div
        ref={modalRef}
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        tabIndex={-1}
      >
        <h2 id="modal-title">{title}</h2>
        {children}
        <button onClick={onClose}>Close</button>
      </div>
    </div>
  );
}
```

### Fix 3: Accessible Form Validation

```jsx
function EmailForm() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!email.includes("@")) {
      setError("Please enter a valid email address");
      return;
    }
    // Submit...
  };

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="email">Email address</label>
      <input
        type="email"
        id="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        aria-invalid={!!error}
        aria-describedby={error ? "email-error" : undefined}
        required
      />
      {error && (
        <span id="email-error" role="alert" className="error">
          {error}
        </span>
      )}
      <button type="submit">Submit</button>
    </form>
  );
}
```

## Testing Tools

**Automated**:

- [axe DevTools](https://www.deque.com/axe/devtools/) (browser extension)
- [Lighthouse](https://developers.google.com/web/tools/lighthouse) (built into Chrome)
- [WAVE](https://wave.webaim.org/) (browser extension)
- [Pa11y](https://pa11y.org/) (CI integration)

**Manual**:

- Screen readers: VoiceOver, NVDA, JAWS
- Keyboard navigation (unplug your mouse!)
- Browser zoom (test at 200%)
- Color contrast tools

## Verification Checklist

- [ ] Ran automated accessibility scanners
- [ ] Fixed all critical violations
- [ ] Tested keyboard navigation (all features accessible)
- [ ] Tested with screen reader (all content accessible)
- [ ] Verified color contrast (4.5:1 minimum)
- [ ] Tested at 200% zoom (no horizontal scroll)
- [ ] Touch targets are 44px+ on mobile
- [ ] Forms have labels and error messages
- [ ] Images have alt text
- [ ] Headings follow logical hierarchy
- [ ] Focus indicators are visible
- [ ] Modals trap focus and handle Escape
- [ ] ARIA used correctly (or not at all)
- [ ] Documented any remaining issues with plan to fix

## Remember

**Good accessibility**:

- Works for keyboard users
- Works for screen reader users
- Works for everyone
- Is built in from the start
- Uses semantic HTML

**Bad accessibility**:

- "We'll add it later" (you won't)
- Relies on automated tools only
- Uses divs for everything
- Removes focus outlines
- Treats it as an afterthought
