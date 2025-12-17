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

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>doc-coauthoring</name>
<description>Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks.</description>
<location>project</location>
</skill>

<skill>
<name>frontend-design</name>
<description>Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.</description>
<location>project</location>
</skill>

<skill>
<name>skill-creator</name>
<description>Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.</description>
<location>project</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
