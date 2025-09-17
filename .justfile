default:
    hugo server -D

new post:
    hugo new content posts/"{{post}}".md
    $EDITOR ./content/posts/"{{post}}".md

