Main branch:
main = stable version only

Create own subbranch after cloning:
- git checkout main
- git pull origin main
- git checkout -b name-part     [kei-backend]

Before making any changes:
- git checkout main 
- git pull
- git checkout name-part
- git merge main

After making changes:
- add commit message
- git push to name-part


merging with main branch
- git checkout current branch
- add commit message and push
- git checkout main
- git pull origin mian
- git merge (branch u want merge)
- git push