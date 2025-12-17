# Agent Personas for Cursor Workflows

This project is a template for describing LLM agentic workflows with tools and documentation, specifically for use with Cursor.

## Project Overview

This repository provides:

- **Agent personas** - Specialized roles for different development tasks
- **Behavior controls** - Prompt suffixes that guide LLM behavior (`llm_behavior_controls.md`)
- **Cursor commands** - Reusable workflows for common development tasks (`commands/`)

## Style Guide

- **Concise and direct** - Each agent persona is a single line with clear purpose
- **Action-oriented** - Focus on what the agent does, not how to use it
- **Specific expertise** - Each agent has a narrow, well-defined domain
- **No examples** - Keep the reference clean and scannable

## Tools & Structure

### Agent Personas

Agent personas are organized by domain:

- Exploration & Experimentation
- Specification & Design
- Language-Specific (Go, React, PostgreSQL)
- Architecture
- Refactoring & Code Quality
- Debugging & Problem-Solving
- Performance
- Documentation
- Developer Experience
- Testing
- Code Review

### Behavior Controls

See `llm_behavior_controls.md` for prompt suffixes that can be appended to guide LLM behavior. These are formatted as:

- "You are a [role]. [Consequence of not following this role]."

### Cursor Commands

Commands in `commands/` directory provide complete workflows for:

- PR management and review
- Code quality and testing
- Development workflows
- Documentation generation

Each command includes purpose, principles, and step-by-step instructions.

## Usage

Reference agent personas by name when working with LLMs in Cursor. Combine with behavior controls from `llm_behavior_controls.md` for focused, specialized assistance.
