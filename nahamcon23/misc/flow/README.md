# NahamCon 2023

## Flow

> We hope you brought your threat modeling experience. Today we have three open sourced AWS architecture diagrams for you to inspect and see if you can spot the flaws. Each diagram has at least one element that doesn't belong, spot the flaws and identify what the system is designed to do and you'll solve this little game.
>
>  Author: Intel: Project Circuit Breaker (Sponsor)

Tags: _misc_

## Solution
This challenge is sponsored by Intel. It's a questionaire concering various AWS cloud infrastructures. The first question is to identify what the infrastructure diagram functionality is. The second question is to decide what components are not needed for the design.

### First
Use: OTT video streaming
Components to remove: AWS Elemental MediaConverter

### Second
Use: Data Warehouse
Components to remove: Bastion, Employees, VPC NAT Gateway

### Third
Use: Wordpress Hosting
Components to remove: SSH, Bastion

Flag `flag{04c7a67eb5634cc374334a088ff2a239}`