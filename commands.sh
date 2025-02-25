git config --global user.email "gaspar.argullelo@gmail.com"
git config --global user.name "arggasasao"

Token "ghp_X3h0ajtz0taBWNWMr8jF89IM7scghz3ILI"
Token "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"

git status

git add .gitignore

git commit -m "Added .gitignore to ignore inesesary files."

git push origin main

# Add archinstall to iso
echo "archinstall" | sudo tee -a baseline/packages.x86_64
