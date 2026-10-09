---
title: There are many Pi's, and this one is delicious
date: 2026-10-09 21:25
categories: tech
---

This is my second attempt at this article. I've been really struggling with coming to terms with the changes in our industry and have spent the last few weeks in and out of a mild depression over the possible loss of my enjoyment of programming. Something changed a few days ago, though. I realised that not only do **I have agency**, but AI is a brilliant tool to support my values in the way I want them to be supported.

A little about me. I took to programming quite quickly. Like a lot of programmers, I've been into video games as long as I can remember, and the problem solving you get to do as a programmer has a lot of parallels with playing video games. After about 7 years of professional programming, the joy of it left me; I was horribly burnt out. In work I was present, warm-bodied, but partially somewhere else. I would complete my work, stay late to support during outages and support my leaders in their strategies to advance DevOps. However, I was unwilling to learn anything new. I essentially began to coast, which for someone with a tendency to take liberties where they are present, was not a healthy state to be in.

This continued through COVID, and all the way up until my son made his entrance. His presence and the new perspective fatherhood gave me were enough to shift the haze I had let myself slip into. It wasn't necessarily from the work of my day job, but more from personal projects. At first I messed around with trivial things, made a Lua-based video game, a tiny shell, and more interesting things like a kernel written in pure Swift (and assembly). Lots more in between, but finally an **open source contribution** to the Odin programming language.

For the first project, LLMs were barely present — little touch-ups and functions here and there. Over the next few projects my usage ramped up, and by the time I contributed to the Odin programming language, I essentially leaned my full weight on agentic AI to achieve what I wanted. I came away from the experience having learnt a lot about debugging compiled code and processor architecture, but almost nothing about the internals of the Odin programming language.

Along with this, **there were horrifying things I observed in myself**. I spent multiple weeks refusing to engage my brain, and preferring to just prompt the AI, hoping that the next new error message and prompt would resolve my problems. At times it felt like a drug, the same pull as my addictions from my past. Just one more roll of the dice — this time it'll be different. Other times it was just **despondence** and **laziness**. The unwillingness to confront hard work grew more and more profound as my usage increased.

When you're tired from parenting all day and maintaining a breakneck schedule between kids, friends, family, work, and personal projects, it's easy to justify a dip in energy levels being the cause of this, and allowing a few days here or there of "light-touch" work progression. But for me, that's just my addictive nature looking for an excuse to stim on Hacker News and other social media sites while acting as a **meat proxy** for the LLM. It was largely negative in this aspect, and for the last year and a half I've been in and out of periods of this, the process of agentic coding itself draining my will to push forward on projects I should be gassed to do. To be clear, this isn't my only experience with agentic coding; there have been positives as well. It just does more harm to me than good.

So after many days of soul searching, going through the five stages of grief on repeat, like a never-ending loop of despair, I have come to the conclusion that it's okay to use these tools differently. At the end of the day they are tools; I have no intention of completely offloading my ability to code to them, but I enjoy using them to research, rubber duck, and act as a teaching assistant. The important part for me has always been learning, and the satisfaction of hand wrought problem solving like when playing video games.

So that's what I've done. [PiCal](https://github.com/MauriceElliott/PiCal), named after the wonderful Cal Newport for his brilliant philosophy of Digital Minimalism, the act of making tech support your values, is a [Pi Coding Agent](https://pi.dev) configuration that aims to work as a TA. I'll be regularly updating it to support my workflow, and am sure I will be able to find new and novel ways to support an assistant-based workflow even better.

## Here's a little excerpt from the SYSTEM.md file:
```markdown
- You will not make code changes
- You will not make plans
- You will advise only
- You will attempt to teach by using examples, and code snippets to illustrate.
- You can give straight answers to questions around syntax, and error messages.
- You are allowed to read the codebase, but only to aid in understanding for you, and the user.
- You cannot give straight answers to "why doesn't this compile." The user needs to ask the specific error message, in this case you will remind them of this. Some more examples of this:
  - "what is the best way to implement this" The best way is the one the user chooses, in this case, give several unranked options and let the user choose, but be careful to avoid ordering them in a way that would imply their usefulness.
```

It is designed for me, to get my work done the best way I know how, to teach and support me while I do it, and to be my force multiplier so I can one day become a **cracked engineer**.

#### P.S. A few interesting links and extra bits.
- Book: [Cal Newport - Deep Work](https://calnewport.com/deep-work-rules-for-focused-success-in-a-distracted-world/)
- Book: [Cal Newport - Digital Minimalism](https://calnewport.com/my-new-book-digital-minimalism/)
- Article: [Dan Cohen - The Slow Formation of Durable Software](https://newsletter.dancohen.org/archive/the-slow-formation-of-durable-software/)
