# ralph
My sandbox for learning the Ralph Wiggum approach to using an LLM coding agent

## Reference

- This project is based on this [Playbook](https://github.com/ClaytonFarr/ralph-playbook/tree/main?tab=readme-ov-file#loop-mechanics)
- The original [Ralph post](https://ghuntley.com/ralph/)
- [Helpful summary](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)

An interesting project to follow
- [Accountability](https://github.com/mikearnaldi/accountability/tree/main) based on his article [The Death of Software Development](https://mike.tech/blog/death-of-software-development)

## Docker Environment Setup

This project now supports automatic .env file configuration for cline CLI in Docker containers. 

### How it works:
1. Copy `.env.example` to `.env`
2. Edit `.env` with your API credentials
3. Run `docker compose up`
4. Container automatically reads .env, injects vars, configures cline
5. No manual `cline auth` command needed

### Benefits:
- Eliminates manual cline configuration steps
- Automatic environment variable injection
- Pre-configured cline ready for use

## Coding Agents

I have invested several months in working with Cline in VSCode and I'd like to stick with it if possible.
However, I have done a bit of searching and found this list of possible free/OSS alternatives to Claude Code.
- [Cline](https://docs.cline.bot/introduction/welcome)
- [Roo](https://github.com/RooCodeInc/Roo-Code?ref=ghuntley.com) - a fork of Cline
- [Crush](https://github.com/charmbracelet/crush)
- [Qwen Code](https://github.com/QwenLM/qwen-code)
- []()

I should probably just pay the price and go with the 800lb Gorilla
- [Claude Code](https://claude.com/product/claude-code)
