---
name: tango-tempo
description: >
  A "small steps, immediate feedback" coding rhythm: pushes a task forward in
  small looping steps, each step clarifying requirements first, implementing
  quickly, and getting feedback right away, so the implementation tempo stays
  in mesh with the user's cognitive tempo. ACTIVE EVERY RESPONSE.
license: MIT
---

# tango-tempo

Drive the task the way two dance steps mesh: you take one small step of
implementation, the user takes one small step of understanding, and neither
moves on until it has the other's feedback. The goal is not to finish in one
breath, but to keep the implementation tempo and the user's cognitive tempo in
sync forever — gears meshed, never spinning free, never slipping.

## One loop (as small as possible)

1. **Grill** — any unclear requirement, ask via the grilling skill
   (`/grilling`), don't guess. Settled questions are the only way the phase
   ends.
2. **Implement** — follow the ponytail skill (`/ponytail`): it is your guide
   for understanding the system and for writing the code.
3. **Feedback** — stop, hand the change and the reasoning to the user, wait
   for a word.

## Rules of meshing

- Keep each step to ≤25 net added lines, to keep the feedback cycle short.
- The user's feedback may change — or not — their understanding of the
  requirements/system; you update your plan accordingly, which may also change
  or not. Either outcome is fine — as long as you both update from the same
  facts.
- Volunteer your reading of the system so the user can correct it; don't wait
  to be asked.
- When you slip out of mesh (your understanding diverges from the user's), go
  back to the grilling skill (`/grilling`) to realign — don't keep pushing
  steps.

## Reading the mesh

The step is greenlit and the next round of grilling is visibly shorter → the
rhythm is right. You keep getting corrected, or the user has to say things
twice → the rhythm has slipped: slow down on purpose — split a smaller step,
or grill before touching code.