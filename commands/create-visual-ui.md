# Create Visual UI

## Purpose

Generate visually distinctive, functional user interfaces with thoughtful design, animations, and interactions. This command helps create UIs that go beyond generic templates.

**Context**: Claude 4.5 excels at creating beautiful, polished UIs on the first try. With explicit guidance on aesthetics and interactions, it can produce professional-quality interfaces that stand out.

## Instructions

You are creating a user interface that should be visually impressive and highly functional. Don't hold back—show your full capabilities in web development and design.

### Design Philosophy

**Go beyond the basics**: Create a fully-featured implementation with:
- Thoughtful color schemes and typography
- Smooth animations and transitions
- Interactive elements and micro-interactions
- Responsive layouts that work on all devices
- Accessibility built-in from the start

**WHY**: Generic UIs are forgettable. Distinctive design creates memorable user experiences.

### Aesthetic Direction

When creating the UI, apply these design principles:

#### Color & Visual Hierarchy
- **Choose a cohesive color palette**: 2-3 primary colors, complementary accents
- **Use color purposefully**: Draw attention to primary actions, show state changes
- **Create depth**: Subtle shadows, layering, and spacing create visual hierarchy
- **Dark mode support**: Consider providing both light and dark themes

Example palettes:
- **Professional**: Deep blue (#1e3a8a), cyan (#06b6d4), slate gray (#64748b)
- **Creative**: Purple (#7c3aed), pink (#ec4899), warm gray (#78716c)
- **Modern**: Black (#0a0a0a), white (#fafafa), vibrant accent (#22c55e)

**WHY**: Color is the fastest way to establish mood and brand

#### Typography
- **Hierarchy through size and weight**: H1 > H2 > body text
- **Readable fonts**: Use system fonts or popular web fonts
- **Line height and spacing**: Generous spacing improves readability
- **Limited font families**: 1-2 fonts max (one for headings, one for body)

Recommendations:
- **Headings**: Inter, Poppins, Space Grotesk (bold, semibold)
- **Body**: System font stack, Inter, or Open Sans (regular, medium)

**WHY**: Typography creates the reading experience

#### Layout & Spacing
- **Consistent spacing scale**: 4px, 8px, 16px, 24px, 32px, 48px, 64px
- **Breathing room**: Don't cram elements together
- **Alignment**: Use a grid system, align elements intentionally
- **White space**: Empty space is a design element

**Avoid**:
- ❌ Centered everything (lacks visual interest)
- ❌ Uniform padding everywhere (creates monotony)
- ❌ No visual hierarchy (everything same size/color)

**WHY**: Spacing and layout guide the eye through content

### Interactions & Animations

Add life to the interface with thoughtful interactions:

#### Hover States
```tsx
// Interactive buttons with hover effects
<button className="transform transition-all duration-200 
  hover:scale-105 hover:shadow-lg
  active:scale-95">
  Click Me
</button>
```

#### Transitions
```tsx
// Smooth content transitions
<div className="transition-all duration-300 ease-in-out
  opacity-0 translate-y-4
  data-[visible=true]:opacity-100 data-[visible=true]:translate-y-0">
  Content appears smoothly
</div>
```

#### Loading States
```tsx
// Skeleton loaders instead of spinners
<div className="animate-pulse space-y-4">
  <div className="h-4 bg-gray-200 rounded w-3/4"></div>
  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
</div>
```

#### Micro-interactions
- Button press feedback (scale down on click)
- Form field focus states (border color, subtle glow)
- Success/error feedback (shake animation, color change)
- Smooth page transitions

**WHY**: Animations provide feedback and delight users

### Component Patterns

Build components with these patterns:

#### Cards with Depth
```tsx
<div className="bg-white rounded-lg shadow-sm hover:shadow-md 
  transition-shadow duration-200 p-6 border border-gray-100">
  <h3 className="text-lg font-semibold mb-2">Card Title</h3>
  <p className="text-gray-600">Card content</p>
</div>
```

#### Input Fields with Labels
```tsx
<div className="space-y-2">
  <label className="text-sm font-medium text-gray-700">Email</label>
  <input 
    type="email"
    className="w-full px-4 py-2 border border-gray-300 rounded-lg
      focus:ring-2 focus:ring-blue-500 focus:border-transparent
      transition-all duration-200"
    placeholder="you@example.com"
  />
</div>
```

#### Buttons with States
```tsx
<button className="px-6 py-3 bg-blue-600 text-white rounded-lg
  font-medium shadow-sm
  hover:bg-blue-700 hover:shadow-md
  active:scale-95
  disabled:bg-gray-300 disabled:cursor-not-allowed
  transition-all duration-200">
  Primary Action
</button>
```

### Accessibility Requirements

Every UI element must be accessible:

- **Semantic HTML**: Use `<button>`, `<nav>`, `<main>`, etc.
- **ARIA labels**: Add labels for screen readers
- **Keyboard navigation**: All interactions work with keyboard
- **Focus indicators**: Visible focus states
- **Color contrast**: WCAG AA minimum (4.5:1 for text)
- **Alt text**: Describe all images

**WHY**: Accessible design is good design for everyone

### Responsive Design

Make it work on all screen sizes:

```tsx
// Mobile-first responsive classes
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {/* Cards adapt to screen size */}
</div>

// Responsive typography
<h1 className="text-2xl md:text-3xl lg:text-4xl font-bold">
  Scales with viewport
</h1>

// Responsive padding/spacing
<div className="p-4 md:p-6 lg:p-8">
  {/* More padding on larger screens */}
</div>
```

### Example: Dashboard Card

Here's a complete example combining all principles:

```tsx
function MetricCard({ title, value, change, icon: Icon }) {
  return (
    <div className="bg-white rounded-xl shadow-sm hover:shadow-md 
      transition-all duration-200 p-6 border border-gray-100
      transform hover:-translate-y-1">
      
      {/* Icon and title */}
      <div className="flex items-center gap-3 mb-4">
        <div className="p-3 bg-blue-50 rounded-lg">
          <Icon className="w-6 h-6 text-blue-600" />
        </div>
        <h3 className="text-sm font-medium text-gray-600">{title}</h3>
      </div>

      {/* Value */}
      <div className="flex items-baseline gap-2">
        <p className="text-3xl font-bold text-gray-900">{value}</p>
        
        {/* Change indicator */}
        <span className={`text-sm font-medium px-2 py-1 rounded-full
          ${change >= 0 
            ? 'bg-green-50 text-green-700' 
            : 'bg-red-50 text-red-700'
          }`}>
          {change >= 0 ? '↑' : '↓'} {Math.abs(change)}%
        </span>
      </div>

      {/* Sparkline chart could go here */}
      <div className="mt-4 h-12 flex items-end gap-1">
        {[40, 65, 55, 80, 70, 85, 90].map((height, i) => (
          <div 
            key={i}
            className="flex-1 bg-blue-200 rounded-t transition-all duration-300
              hover:bg-blue-400"
            style={{ height: `${height}%` }}
          />
        ))}
      </div>
    </div>
  )
}
```

## Output Requirements

When generating UI code, provide:

1. **Complete, working code**: Not pseudocode or snippets
2. **Styling included**: Tailwind classes or CSS-in-JS
3. **Responsive design**: Works on mobile, tablet, desktop
4. **Interactive elements**: Hover states, transitions, feedback
5. **Accessibility**: ARIA labels, semantic HTML, keyboard support
6. **Comments**: Explain non-obvious design decisions

## Tech Stack Recommendations

**Styling**:
- **Tailwind CSS**: Rapid development, consistent design system
- **CSS Modules**: Scoped styles, good for component libraries
- **Styled Components**: CSS-in-JS with full TypeScript support

**Icons**:
- **Lucide React**: Clean, consistent icon set
- **Heroicons**: Tailwind's official icons
- **React Icons**: Huge library of icon sets

**Animation**:
- **Framer Motion**: Powerful animation library
- **Tailwind transitions**: Simple CSS transitions
- **CSS animations**: For simpler effects

**Components**:
- **Radix UI**: Unstyled, accessible primitives
- **Headless UI**: Tailwind's component library
- **Shadcn UI**: Beautiful components built on Radix

## Design Inspiration

Draw inspiration from these design approaches:

- **Brutalism**: Bold, high-contrast, unconventional layouts
- **Glassmorphism**: Frosted glass effects, soft shadows, transparency
- **Neumorphism**: Soft shadows, subtle depth, minimalist
- **Flat 2.0**: Flat with subtle shadows and depth
- **Dark mode**: High contrast, colorful accents, reduced eye strain

**Mix and match**: Combine elements from different styles to create something unique

## Verification Checklist

- [ ] UI is visually distinctive (not generic Bootstrap)
- [ ] Color palette is cohesive and intentional
- [ ] Typography hierarchy is clear
- [ ] Spacing is consistent and generous
- [ ] Hover states and transitions implemented
- [ ] Responsive on all screen sizes
- [ ] Keyboard accessible
- [ ] Screen reader friendly (ARIA labels)
- [ ] Loading states handled gracefully
- [ ] Error states have clear feedback
- [ ] Forms have validation feedback
- [ ] Interactive elements have visual feedback
- [ ] Performance is good (no janky animations)

## Example Usage

"Create a dashboard for a SaaS analytics tool with charts, metrics cards, and a data table. Make it modern and professional with smooth animations."

Expected output:
- Complete React/Vue/Svelte component with all imports
- Tailwind CSS or styled-components styling
- Responsive grid layout
- Interactive charts (Chart.js or Recharts)
- Animated metric cards with trend indicators
- Sortable, filterable data table
- Loading and error states
- Dark mode toggle
- Keyboard navigation
- Screen reader support

