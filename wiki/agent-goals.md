---
created: 2026-07-11
updated: 2026-07-11
---

# Agent Goals

A goal is the other shape of autonomous agent work, complementary to [[agent-loops]]: not a schedule but a finish line. You describe what done looks like once, and the model works alone until it's crossed, with a second, smaller model reading along as the judge that confirms completion.

## Notes

The detail that decides whether a goal is useful or a token bonfire: the judge only sees the conversation. It can't open files, run tests, or check a site. So "done when the tests pass" is a wish, while "done when the full green test run is PASTED in the chat" is a contract. Agents claim "done" all the time without it being true — proof you can read in the transcript is the only version that counts. The [[fable-loop-library]]'s goal-shaped workflows all end the same way: paste the proof, and if you can't, paste the failures and stop.

This makes goal-writing an exercise in evidence design: the done condition must name an artifact that (a) the working model can produce into the conversation and (b) the judge can verify by reading alone. Anything that requires the judge to *do* something is out of contract.

The same discipline applies outside formal /goal runs — any delegation to an agent is better specified as "produce this readable evidence" than "achieve this state of the world."

## Related

- [[agent-loops]] — the recurring-schedule counterpart; loops carry stop rules, goals carry finish lines
- [[fable-loop-library]] — source of this framing, with worked goal contracts
- [[scheduled-automation]] — a place this evidence-design discipline could apply (verifying unattended runs by their committed output)

## Sources

- [[sources/2026-07-11-fable-loop-library]] — defines the goal/judge mechanics and the pasted-proof contract
