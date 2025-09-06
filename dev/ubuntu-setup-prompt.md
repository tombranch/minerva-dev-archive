i have just set this vm with ubuntu for developement can you help optimise this project to suit unix. i also want to improve the dx generally. this project is gettting messy.

Review the current satate of the project.

Read this and let me know 
/home/tom-branch/dev/projects/minerva/convex-feature-migration/dev/02-staging/01-next/claude-code-optimization-report.md

1. optimise this project for unix env
2. replace npm with pnpm 
3. Agents - we have too many. read the best practce here https://docs.anthropic.com/en/docs/claude-code/sub-agents. then create a guide for how to create them here /home/tom-branch/dev/projects/minerva/convex-feature-migration/.claude/agents
   we have too many agent types i think, what are your throughts?

4. slash commands - read this for best practice then create a guide. https://docs.anthropic.com/en/docs/claude-code/slash-commands
again we have too many. the main ones i want are:
a. /plan - 
- create a compreishive plan in manageable phases like this example /home/tom-branch/dev/projects/minerva/convex-feature-migration/dev/03-in-progress/convex-clerk-migration
- use context7 to reasure to uptodate docs
b. /implement [feature]
- i'll give a link to the feature and say which phase you will deliver
- use context7 for docs,
- follow best practice
- do not leave technical debt
- make atomic commits
c. /review-implemation
- review the work 
-create a detailed report on findings and recomdnations. 

are there any other key commands we need?

read this for other ideas we should implemnt to improve dx https://github.com/hesreallyhim/awesome-claude-code

5. i just lost a a days work becasue we where commiting locally but didnt push to remote. can you find a fix for this?

6. MCPs research and find me the commands to installthe following:
- context7
- playwright
- convex
-github
- clerk
- other recommdantions for this project

7. i have been using the /dev folder as a project management tool. could we set up github projects and issues for this? 

8. vs code - what extensions should i install?

9. i want to clean up the project root.

10. update claude.md

have i missed anything? i want you to ULTRA THINK about this to refine the dev setup and workflow. i am a solo dev that relies exclusily on claude code.

