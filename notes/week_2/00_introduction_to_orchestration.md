# Introduction to Orchestration

## Definition

Data engineering primarily relates to extraction, transformation, and loading of data. *Orchestration* refers to an automated process that manages the dependencies of the various steps in data engineering. It includes managing schedules and triggers, monitoring the process, and allocating resources.

A sequence of steps carried out in data engineering is known as a *workflow* or a *DAG* (Directed Acyclic Graph). Each step is also known as a *task*.

Features of a good orchestration tool include:

- Workflow management
- Automation
- Error handling
- Recovery
    - Backfill or recover missing data
- Monitoring and alerting
- Resource optimisation
- Observability
    - Visibility into every part of the data pipeline
- Debugging
- Compliance and auditing

Along with engineering features, a good orchestrator also enhances developer experience by:

- enabling flow state
- reducing feedback loops for quick iteration
- bringing down cognitive load so that the developer can focus on the business problem

## Resources

- [What is Orchestration?](https://www.youtube.com/watch?v=Li8-MWHhTbo&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb)