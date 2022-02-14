# example_lucky_app2

This is an example dockerized Lucky Framework app, initialized as an `full` (not `api` only) app and with default auth set up.

TODO:
- [ ] Unpend/resolve the 3 pend'ed tests (db conn issues).

Next steps:
* Create a new repo.
* Copy the contents of this repo (without the `.git` folder) to your new repo
* Add your migrations/scaffolds/tests/etc, as desired.

---
## Build the container image and launch it
* `docker-compose build`
* `docker-compose up -d`

NOTE: Before re-building the container, you'll need to run the following to clean up after Overmind:

* `script/docker_cleanup_before_next_build.sh`

After initial loading of the Lucky app, it will show the default home page (http://localhost:3001/), which will have the following text:

```markdown
LUCKY

[CHECK OUT THE GUIDES](https://luckyframework.org/guides) | [VIEW YOUR NEW APP](http://localhost:3001/sign_up)

Not sure where to start? Here are some ideas:

Change what this page renders -> [src/actions/home/index.cr](src/actions/home/index.cr)

Generate a model, set of actions, and HTML -> `lucky gen.resource.browser Post title:String`

Ask for ideas in our chatroom -> [https://discord.gg/HeqJUcb](https://discord.gg/HeqJUcb)
```

If you click on [VIEW YOUR NEW APP](http://localhost:3001/sign_up), it will take you to a page that asks you to create a user and which will have the following text:

```markdown
# Sign Up
Email
[                ]
Password
[                ]
Confirm Password
[                ]
[Sign Up]
[Sign in instead](http://localhost:3001/sign_in)
```

After creating a user, it will take you to the `me` profile page, which will have text like the following:

```markdown
drhuffman12@gmail.com - Sign out

# This is your profile

Email: drhuffman12@gmail.com
Next, you may want to:
* Check out the authentication guides
* Modify this page: src/pages/me/show_page.cr
* Change where you go after sign in: src/actions/home/index.cr
```

---
## Running tests

From the Host OS terminal, open a terminal into the container's image:
* `docker-compose run app bash`

From the Container's terminal, enter the following to run the tests:
* `crystal spec`
