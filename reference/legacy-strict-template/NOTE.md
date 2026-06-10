# Superseded — kept as prior art

This is the original v1 fixed boilerplate: a fully specified two-session
Lead/Scientist research protocol meant to be copied per project.

It is superseded by the adaptive setup prompts in `../../prompts/`, which carry
these mechanisms as a menu of options rather than a mandatory layout. Kept here
because the mechanisms are battle-tested and worth reading when deciding what a
mature project should adopt: pre-registration with tamper checks, the
killed-hypothesis register, scale-bound verdicts, retroactive invalidation, the
loop-health retro checklist, frozen-artifact manifests, directory-hygiene rules.

Do not extend this template — backport lessons into the prompts instead.

## Known gap

The `scientific-code-reviewer` agent definition that the role files, README step 6,
and `init-research-project.sh` all reference was never part of this template — it
lived at `~/.claude/agents/scientific-code-reviewer.md`, outside any project tree,
and is not included here. Direct users of this template must supply their own
reviewer agent; the adaptive prompts in `../../prompts/` instead generate a
project-tailored reviewer at setup time, which is the recommended path.
