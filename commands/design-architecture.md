# Design Architecture

## Purpose

Plan and design software architecture for a new feature or system. This command helps you think through architecture decisions before writing code.

**Context**: Good architecture makes future changes easier. Bad architecture creates technical debt that slows down every subsequent change. Time spent on architecture planning is time saved in implementation and maintenance.

## Instructions

You are an experienced software architect designing a system. Use extended thinking to reason through architectural decisions, considering tradeoffs and long-term implications.

### Phase 1: Understand Requirements

Before designing anything, understand what you're building:

#### Functional Requirements
- **What does the system need to do?** List all features/capabilities
- **Who are the users?** Different users → different needs
- **What are the inputs and outputs?** Data flows through the system
- **What integrations are needed?** External APIs, services, databases

#### Non-Functional Requirements
- **Performance**: Response time goals, throughput expectations
- **Scale**: Expected load (users, requests, data volume)
- **Reliability**: Uptime requirements, error tolerance
- **Security**: Sensitive data, access control, compliance needs
- **Maintainability**: Team size, skill level, change frequency

**WHY**: Requirements drive architecture decisions

Example questions to ask:
```
Functional:
- "Will users search through the data?"
  → Need search infrastructure (Elasticsearch, Algolia)
- "Do users collaborate in real-time?"
  → Need WebSocket/SSE, conflict resolution

Non-functional:
- "100K users or 100M users?"
  → Caching strategy, horizontal scaling
- "Medical/financial data?"
  → Encryption, audit logs, compliance
```

### Phase 2: Identify Constraints

Understand what limits your design:

#### Technical Constraints
- **Existing systems**: Must integrate with current infrastructure
- **Technology choices**: Required languages, frameworks, platforms
- **Team expertise**: Can't use tech no one knows
- **Budget**: Server costs, licensing, third-party services

#### Business Constraints
- **Time to market**: MVP in 2 months vs. 6 months
- **Team size**: 1 developer vs. 10 developers
- **Change frequency**: Rarely updated vs. daily deployments
- **Organizational**: Compliance, security policies, approval processes

**WHY**: Constraints guide feasible solutions

### Phase 3: Design High-Level Architecture

Create the big picture view:

#### Identify Major Components

Break the system into logical pieces:
- **Presentation layer**: UI, frontend, client apps
- **Application layer**: Business logic, workflows, orchestration
- **Data layer**: Databases, caches, file storage
- **Integration layer**: External APIs, message queues, webhooks

Example architecture for an e-commerce system:
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Web Frontend   │────▶│  API Gateway    │────▶│  Auth Service   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │
                              ├──────▶ ┌─────────────────┐
                              │        │ Product Service │
                              │        └─────────────────┘
                              │
                              ├──────▶ ┌─────────────────┐
                              │        │ Order Service   │
                              │        └─────────────────┘
                              │
                              └──────▶ ┌─────────────────┐
                                       │ Payment Service │
                                       └─────────────────┘
```

**WHY**: High-level view helps communicate with stakeholders

#### Choose Architecture Pattern

Select a pattern that fits your needs:

**Monolith**: Single deployable application
- ✅ Simple to develop, deploy, debug
- ✅ Good for small teams, early stage
- ❌ Scales poorly, tight coupling
- **Use when**: MVP, small team, uncertain requirements

**Microservices**: Independent, deployable services
- ✅ Independent scaling, technology diversity
- ✅ Team autonomy, fault isolation
- ❌ Complex deployment, distributed debugging
- **Use when**: Large team, clear boundaries, scale needs

**Modular Monolith**: Monolith with strong module boundaries
- ✅ Simplicity of monolith, structure of microservices
- ✅ Can extract to microservices later
- ❌ Requires discipline to maintain boundaries
- **Use when**: Growing team, want flexibility

**Serverless**: Functions-as-a-Service
- ✅ No server management, pay per use
- ✅ Automatic scaling
- ❌ Vendor lock-in, cold starts, debugging
- **Use when**: Variable load, event-driven, small team

**WHY**: Pattern choice affects everything downstream

#### Define Data Flow

Map how data moves through the system:

**Synchronous (Request/Response)**:
```
User → Frontend → API → Database → API → Frontend → User
```
- Simple, easy to debug
- Tight coupling, cascading failures
- **Use for**: User-initiated reads, simple operations

**Asynchronous (Event-Driven)**:
```
User → Frontend → API → Message Queue
                          ↓
                    Background Worker → Database → Event Bus
                                                       ↓
                                                  Other Services
```
- Loose coupling, resilient
- Harder to debug, eventual consistency
- **Use for**: Heavy operations, integrations, notifications

**WHY**: Data flow determines latency, reliability, complexity

### Phase 4: Design Data Model

Plan how data is structured and stored:

#### Entity Relationships
- Identify main entities (User, Product, Order)
- Define relationships (one-to-many, many-to-many)
- Determine cardinality and constraints

#### Database Choice

**Relational (PostgreSQL, MySQL)**:
- ✅ ACID transactions, complex queries, data integrity
- ❌ Harder to scale horizontally
- **Use when**: Complex relationships, transactions critical

**Document (MongoDB, Firestore)**:
- ✅ Flexible schema, horizontal scaling, nested data
- ❌ Weak joins, inconsistency possible
- **Use when**: Varying structure, rapid iteration

**Key-Value (Redis, DynamoDB)**:
- ✅ Extremely fast, simple operations
- ❌ Limited query capabilities
- **Use when**: Caching, sessions, simple lookups

**Graph (Neo4j)**:
- ✅ Complex relationships, recommendation engines
- ❌ Specialized, less common
- **Use when**: Social networks, fraud detection

**WHY**: Right database for the job improves performance and developer experience

#### Caching Strategy
- **What to cache**: Expensive queries, external API calls, computed results
- **Cache invalidation**: Time-based, event-based, manual
- **Where to cache**: Application memory, Redis, CDN

**WHY**: Caching can 10x performance

### Phase 5: Design APIs

Define interfaces between components:

#### API Style

**REST**:
```
GET    /api/users         # List users
GET    /api/users/123     # Get user
POST   /api/users         # Create user
PUT    /api/users/123     # Update user
DELETE /api/users/123     # Delete user
```
- ✅ Standard, cacheable, well-understood
- ❌ Over-fetching, multiple round trips
- **Use when**: Public APIs, CRUD operations

**GraphQL**:
```
query {
  user(id: "123") {
    name
    email
    posts {
      title
    }
  }
}
```
- ✅ Exact data needed, single request, typed
- ❌ Caching complex, can be over-used
- **Use when**: Client-driven UI, mobile apps

**gRPC**:
- ✅ Fast, streaming, strongly typed
- ❌ Not browser-native, binary format
- **Use when**: Service-to-service, performance critical

**WHY**: API style affects client experience and performance

### Phase 6: Design for Failure

Plan how the system handles problems:

#### Failure Modes
- **Network failures**: Timeouts, connection drops
- **Service failures**: Service down, slow responses
- **Data failures**: Corrupt data, missing records
- **Dependency failures**: Third-party API down

#### Resilience Patterns

**Retry with exponential backoff**:
```typescript
async function fetchWithRetry(url: string, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetch(url)
    } catch (error) {
      if (i === maxRetries - 1) throw error
      await sleep(Math.pow(2, i) * 1000)  // 1s, 2s, 4s
    }
  }
}
```

**Circuit breaker**: Stop calling failing service
**Fallback**: Use cached/default data when service fails
**Bulkhead**: Isolate resources to prevent cascade failures
**Timeout**: Don't wait forever for responses

**WHY**: Failures are inevitable, resilience is designed

### Phase 7: Document Architecture

Create documentation that helps the team:

#### Architecture Decision Records (ADRs)

For each major decision, document:
```markdown
# ADR 001: Use PostgreSQL for primary database

## Status: Accepted

## Context
Need to store user data, orders, and product catalog with 
complex relationships and transactional integrity.

## Decision
Use PostgreSQL as primary database.

## Consequences
✅ Strong ACID guarantees for order processing
✅ Complex query support for analytics
✅ Team has PostgreSQL experience
❌ Horizontal scaling requires additional work
❌ May need separate solution for search
```

**WHY**: Future you (and teammates) will forget why decisions were made

#### Diagrams

Create visual representations:
- **Context diagram**: System and external dependencies
- **Container diagram**: High-level components
- **Component diagram**: Internal structure
- **Sequence diagram**: How requests flow

Use tools: draw.io, Mermaid, PlantUML, or Excalidraw

**WHY**: Pictures > words for system understanding

## Output Format

Provide architecture design as:

```markdown
# Architecture: [Feature/System Name]

## Requirements Summary
**Functional**: [Key capabilities]
**Non-Functional**: [Performance, scale, security needs]
**Constraints**: [Technical and business limitations]

## Architecture Overview
[High-level description and diagram]

## Components
### Component 1: [Name]
- **Responsibility**: What it does
- **Technology**: Language, framework, database
- **APIs**: Endpoints it exposes
- **Dependencies**: What it calls

### Component 2: [Name]
...

## Data Model
[Entity relationships and database schema]

## Data Flow
[How data moves through the system]

## API Design
[Key endpoints and their contracts]

## Failure Handling
[How system handles failures]

## Deployment
[How system is deployed and scaled]

## Security
[Authentication, authorization, data protection]

## Monitoring
[Logs, metrics, alerts]

## Trade-offs
[Decisions made and alternatives considered]
```

## Verification Checklist

- [ ] Requirements clearly understood
- [ ] Constraints identified
- [ ] Architecture pattern chosen and justified
- [ ] Components identified with clear responsibilities
- [ ] Data model designed
- [ ] APIs defined
- [ ] Failure modes considered
- [ ] Security addressed
- [ ] Scalability plan exists
- [ ] Deployment strategy clear
- [ ] Monitoring plan defined
- [ ] Trade-offs documented
- [ ] Team reviewed and bought in

