#/bin/bash
docker compose up -d
ansible-playbook -i inventory/prod.yml site.yml --vault-password-file ./.vault_pass.txt
docker compose down
