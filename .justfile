alias n := new
alias e := edit

default:
  hugo server -D

new post:
  hugo new content posts/"{{post}}".md
  $EDITOR ./content/posts/"{{post}}".md

edit:
  $EDITOR "$(find content/posts -maxdepth 1 -type f | fzf)"

