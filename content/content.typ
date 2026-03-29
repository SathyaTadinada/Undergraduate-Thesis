#let footnote_link(url) = footnote(link(url))

= Introduction

FreezeTag is a free and open-source, self-hosted image management application developed for the University of Utah's Kahlert School of Computing senior capstone project during the Fall 2025 and Spring 2026 semesters by Ethan Collier, Brayden Jonsson, Max Petersen, and Sathya Tadinada (the author). FreezeTag is designed to give photographers, businesses, and hobbyists a way to store, organize, and retrieve their photos without depending on a cloud-based service. The application runs on hardware the user already owns, exposes its interface through a web browser, and allows users to attach custom tags and metadata to their images so that specific photos can be found quickly even across very large collections.

A core problem FreezeTag addresses is that existing image management solutions force users to choose between convenience and control. Services like Google Photos and Apple Photos are easy to use and widely accessible, but they store data on remote servers owned by third parties, charge recurring fees that grow with the size of a user's collection, and offer little to no ability to customize how the software behaves. On the other end of the spectrum, tools like DigiKam #footnote_link("https://www.digikam.org/") provide local storage and more configurability, but require the application to be installed on every device the user wants to access their photos from, and setting up networked access across multiple machines is a cumbersome manual process. Neither category of solution works well for the kinds of users FreezeTag targets, which include freelance photographers managing large client libraries, small businesses that need to self-host for data security or compliance reasons, and technically-inclined hobbyists who already run their own network-attached storage devices and want software that fits into that infrastructure.

A second problem is how most image management tools handle organization and search. The dominant approach across nearly every major solution is folder-based organization, where photos are sorted into a hierarchy of directories, often by date or by some manually-maintained folder structure. Google Photos organizes images chronologically and offers an AI-powered search that can recognize objects and faces, but it does not give users a way to define and apply their own categorical labels in any structured way. DigiKam supports tags in principle, but the tagging system is secondary to its folder-based model and is not designed around search as a primary use case. Apple Photos has albums, which function similarly to folders, and its search is limited to metadata that the app itself recognizes automatically. In general, none of these tools treat user-defined tags as a first-class feature, meaning that a photographer who wants to label images by client name, usage rights, subject matter, and shooting location simultaneously has no good way to do that and then query across all of those dimensions at once.

FreezeTag treats tags as the primary organizational unit of the application. Rather than asking users to maintain a folder hierarchy, FreezeTag allows any number of tags to be attached to any image, and those tags are stored in a searchable database alongside automatically extracted EXIF metadata. A user can apply tags like "client:Acme", "location:SaltLake", and "format:print" to a batch of images at upload time, and then later retrieve exactly that subset of their collection by searching across any combination of those tags. This model scales much more naturally to large or complex libraries than folder structures do, because a single image can belong to multiple logical groupings without needing to be duplicated or symlinked across directories.

FreezeTag addresses the self-hosting problem by running as a web server on hardware the user provides. Because the interface is entirely browser-based, any device on the same network can connect to a single FreezeTag instance without any software installation on the client side. Photos are stored locally and deployment is handled through Docker Compose, which means getting a FreezeTag instance running requires only a single command, and the environment is consistent regardless of what operating system the host machine is running.

Beyond the core tagging and gallery functionality, FreezeTag is designed to be extensible through a Python-based plugin system. The Go backend server can load, run, and manage plugins that add new capabilities to the application, and because plugins are written in Python, they have access to the full Python ecosystem, including machine learning libraries like PyTorch #footnote_link("https://pytorch.org/") and TensorFlow #footnote_link("https://www.tensorflow.org/"). FreezeTag ships with several first-party plugins, including automated face recognition, local image captioning, location tagging based on GPS coordinates, and bulk export tools. Community-developed plugins are also supported, and a public plugin API makes it possible for developers outside the team to build and distribute their own extensions. This plugin architecture was central to the design philosophy of FreezeTag from the beginning: rather than trying to anticipate every possible use case and bake it into the core application, the goal was to build a solid, minimal foundation that could be extended to fit nearly any workflow.

The team was organized into two frontend engineers and two backend engineers, with each member owning a specific area of the codebase. As the frontend interface engineer, my responsibilities centered on the visual design and implementation of the user-facing portions of the application, including the gallery, the tagging panel, and various other pages. My Rank 3 features were a first-party plugin for displaying photo locations on an interactive map, and custom theme importing functionality that allows users to load and apply their own color themes to the FreezeTag interface. We used an Agile development process organized around one-week sprints, with standups, code reviews, and sprint retrospectives throughout both semesters of development. The following chapters cover the technical architecture of the system, the engineering practices we adopted as a team, my individual contributions in more detail, and a reflection on what the project taught me about software development in a collaborative setting.

#pagebreak(weak: true)

= Introduction

_TradeTracker_ is a mobile and web application that was developed for the University of Utah's Kahlert School of Computing senior capstone project during the Spring 2025 and Fall 2025 semesters by Andy Hsu, Jie Lin, Thomas Stratford, Chase Harkcom (the author of this thesis).
_TradeTracker_ eases some of the difficulties that trading card game (TCG) collectors and players face when participating in the hobby.
A very common problem that TCG collectors face is managing their collection; there are thousands of trading cards in the most popular TCGs.
For a TCG collector to determine if they own a card, they need to manually search through their physical collection of cards or manually query and maintain a digital record of collected cards.
Remembering details about every card that one owns, like the current market price, is impossible, so many collectors turn to external tools, such as _TCGPlayer_, to determine the value of individual cards.

Another major problem that TCG players face is socialization.
All currently popular TCG formats require multiple players, so it's essential to find other people to join.
TCG players either need to be "in the know" to find events and tournaments where they can play with others, or they need to do lots of research across many platforms to find nearby card shops and their event schedules.
Moreover, players being able to readily trade cards with other players is a very important part of the hobby since it encourages people to experiment with different card types and strategies when playing.

_TradeTracker_ addresses the problems of manual trading card collection management and cumbersome sociability by facilitating card collection management and giving players a dedicated, centralized forum in which they can socialize.
The application eases collection management by allowing users to scan a photo of one or more cards with their camera, after which it will identify the card(s), prompt the user to confirm that the card(s) were identified correctly, and finally add the cards to their virtual collection.
Once the user verifies that the cards were correctly scanned and added to their collection, they can easily search and filter through their collection to see more details about the card, including its current market price.
The application facilitates socialization by allowing users to submit posts that other users can see and interact with, along with having in-app direct messaging and trading functionality.
For example, one user can make a post saying that they are willing to trade certain cards for other certain cards.
From there, the users can directly message each other and negotiate a trade.
Finally, once they physically trade the cards, both users can confirm the trade in the app, and both of their digital collections will update accordingly.
By addressing these difficulties, we hope _TradeTracker_ gives TCG collectors and players alike a centralized place to participate and enjoy the trading card game hobby.

We used Agile methodologies and Scrum practices to develop our project, mirroring how much of the modern software development industry operates.
Agile is an approach to developing software that focuses on adapting to changes and teams self-organizing based on what works best for them #footnote_link("https://agilealliance.org/agile101/").
Scrum is a product development framework that is often used alongside Agile, which includes organizing tasks into lists called "backlogs" and fixed intervals called "sprints" #footnote_link("https://agilealliance.org/glossary/scrum/").
At the end of each sprint, the team is to meet to review the results of the sprint and perform a retrospective, reflecting on how things went during the sprint.
Moreover, Scrum describes a few roles, such as the "Scrum Master" and "Product Owner," to facilitate the completion of tasks through the backlogs and sprints.
For our project, we applied Agile and Scrum by organizing our work into two-week sprints, performing stand-up meetings twice a week (alongside meetings with the course staff once a week), estimating issues at the beginning of every sprint, and performing a sprint retrospective at the end of each sprint.
We didn't perform all of the different techniques suggested by the Scrum framework---part of working in an Agile format is to do whatever works best for the team, so we stuck with what was most comfortable for us, while factoring in our shared feedback from sprint retrospectives.
Thus, we did not intentionally allocate specific "Scrum Master" or "Product Owner" roles; we treated each other as equal software developers.
However, as the team member writing a thesis on how we used agile practices, leading most meetings, and making sure that our issue board was up to date, I was acting as a de facto "Scrum Master".

// Should I put anything else here?

#pagebreak(weak: true)

= Background and Technical Requirements
As mentioned previously, _TradeTracker_ is an application that aims to aid TCG players and collectors.
Specifically, we identified the following user groups that would be inclined to use our app:
- Hobbyists
- Influencers
- Investors
- Professional players
- Card shop owners
- Tournament/event organizers

Numerous other mobile apps provide similar card scanning/identification functionality, including _Poke TCG_ #footnote_link("https://apps.apple.com/us/app/pok%C3%A9-tcg-scanner-dragon-shield/id1199495742"), _Collectr_ #footnote_link("https://apps.apple.com/us/app/collectr-tcg-collector-app/id1603892248"), and _PokeTCG Sim_ #footnote_link("https://apps.apple.com/us/app/poketcg-sim-open-card-packs/id1635855177").
These apps primarily focus on the financial aspect of collecting cards, but not so much the social and community-driven aspects.
They primarily target the "investor" and "influencer" user base, who are interested in making a profit on the card market instead of the "game" parts of TCGs.
Our app aims to cater to both financially and community-driven TCG consumers.
We will provide similar services, like card price lookup and integration with card marketplaces to accommodate financially-driven players, as well as community-driven resources like event listings and inter-user communication.
Also, our app is currently supporting the three most popular trading card games in the United States: _Pokémon TCG_, _Yu-Gi-Oh!_, and _Magic: The Gathering_.

_TradeTracker_ was built by four developers in about 6 months of active development time, with each developer spending approximately 10 hours per week on the product.
Development started in the latter half of the Spring 2025 semester (around April), was paused over the summer (from around May to late August), was resumed at the beginning of the Fall 2025 semester (late August), and finished development near the end of the Fall 2025 semester (late November).
We used GitLab for hosting our code repository, issue board, and wiki.
The developers on the project were:

- Chase Harkcom (me), Primary Backend Developer and DevOps Engineer.
- Thomas Stratford, Computer Vision Lead and Backend Developer.
- Andy Hsu, Full-Stack Developer.
- Jie Lin, Frontend Developer.

We used the FastAPI #footnote_link("https://fastapi.tiangolo.com/") library for our backend server/REST API and SQLite for our database.
We chose FastAPI because Andy and I had just used it in our _Web Development 2_ course here at the University of Utah.
We considered using Django #footnote_link("https://www.djangoproject.com/") (the framework that was used in the _Web Development 1_ class) instead, but we ultimately chose FastAPI.
We chose FastAPI because it allows for much more customizability with how the application lifecycle runs (easing the usage the image classification/computer vision libraries that will be mentioned later), is much more popular framework in the industry, and we just preferred the framework over Django; Django is more attuned for being a full-stack web framework, while we only cared about having a backend server/API, so FastAPI seemed like the best fit overall.
Another benefit of using FastAPI is that it automatically generates an OpenAPI specification for API routes, meaning we could easily generate Swagger API documentation and automate route/type synchronization between the frontend and backend.

We used a few other libraries in our backend server, including _pytest_ #footnote_link("https://docs.pytest.org/en/stable/") for comprehensive unit testing, _SQLModel_ #footnote_link("https://sqlmodel.tiangolo.com/") for database-code interaction, and _Alembic_ #footnote_link("https://alembic.sqlalchemy.org/en/latest/") to create automated database migrations.
By the end of development, we had 54 endpoints and 127 unit tests for those endpoints, testing all possible errors that can be thrown (e.g., not authenticated, unauthorized resource access, etc).
We implemented user authentication and authorization using JSON web tokens, leveraging _bcrypt_ #footnote_link("https://pypi.org/project/bcrypt/") and _python-jose_ #footnote_link("https://python-jose.readthedocs.io/en/latest/"), alongside the Google Credentials API for Google account integration.
Finally, we used a few external APIs to populate our databases with card data:

#list(..(
  ("Pokémon TCG Developers", "https://pokemontcg.io/", [_Pokémon TCG_ card data]),
  ("YGOPRODeck", "https://ygoprodeck.com/api-guide/", [_Yu-Gi-Oh!_ card data]),
  ("MTG Developers", "https://docs.magicthegathering.io/", [_Magic: The Gathering_ card data]),
  ("JustTCG", "https://justtcg.com/", [card price data]),
).map(d => {
  let (api_name, api_link, data_type) = d
  [#emph(api_name) #footnote_link(api_link) for the #data_type.]
}))

// TODO: Mention how we downloaded/cached card images to not kill the APIs (a.k.a., we rehosted the images).

We hosted the backend server remotely on an AWS EC2 instance.
Initially, I was using the free tier of AWS resources to host the server (a `t2-micro` instance, which has 1 GiB of memory), but our computer vision models took up too much memory, and the backend server process kept being killed by the operating system.
Thus, I upgraded the instance to a `t2.small` instance, which has 2 GiB of memory.
We used AWS Elastic IP to ensure the IP address of the API was externally accessible and not dynamically changing, and I also configured the DNS records on my personal website to allow for external access to the API on the frontend via an easy-to-remember URL #footnote_link("http://tradetracker.chasehark.com/docs").
My _Web Development 1_ and _Computer Networking_ classes at the university provided me with lots of context for accomplishing these tasks.

I also built and configured a continuous integration (CI) pipeline using a separate EC2 instance, leveraging "GitLab Runner", which is software provided by GitLab to automatically fetch code changes and trigger pipeline execution when certain events occur.
I used this to run our backend unit tests, backend code formatting, and frontend code formatting whenever a pull request was created or updated.
If any of these steps failed, the PR would show a pipeline failure badge on it, which would block merging until the code was updated to fix the errors.
Due to timing, I was unable to create an automated continuous deployment (CD) pipeline; we merged to our production branch only at the end of each sprint, so manually uploading the files to the EC2 instance was not a large hassle.
However, I did create a small Bash script to facilitate the uploading of the code to the server.

For our frontend application, we used the _Expo_ #footnote_link("https://expo.dev/") framework, which is backed by _React Native_ #footnote_link("https://reactnative.dev/").
Using a React Native-based framework allowed us to have a unified codebase for our iOS, Android, and web applications.
We also used a few minor libraries to aid in the frontend development process, including _VisionCamera_, #footnote_link("https://react-native-vision-camera.com/") which provided extra camera features that we needed, (and which the Expo SDK itself did not provide), _Tailwind CSS_ #footnote_link("https://tailwindcss.com/")/_NativeWind_ #footnote_link("https://www.nativewind.dev/") for easier and more ergonomic component styling, _TanStack Query_ #footnote_link("https://tanstack.com/query/") to simplify query state and resource management, and _HeyAPI OpenAPI-TS_ #footnote_link("https://heyapi.dev/openapi-ts/get-started/") for backend API type synchronization on the frontend.

When we were in the pre-production phase of the project, we had a difficult choice to make between using a React Native framework (like Expo) or the popular _Flutter_ #footnote_link("https://flutter.dev/") framework.
Both frameworks are geared toward making multi-platform (i.e., web, iOS, and Android) applications.
Our team deliberated on this choice for a bit, but we ultimately decided on using Expo because most of us had at least some light React experience, meaning we wouldn't have to learn a new language/ecosystem from scratch (as would be the case with Flutter and the Dart ecosystem).
Also, React is a much more popular library in the industry, noting that this would help us gain some valuable experience that could be applied in a professional setting, post-graduation.

// TODO: Include if we put the app on the Google Play Store or Apple App Store.

The final facet of our application is the card scanning computer vision module, which we created to identify trading cards based on scanned images from the mobile application.
This module runs on the backend behind an API endpoint.
When a user scans a card in the app, the image is sent to the backend through that endpoint, where the system attempts to identify and return the canonical identity of the scanned card.
We use several YOLO-based segmentation models to detect, isolate, and align the cards from the provided image.
We employ a cropping and perspective transformation model specific to each card game (_Pokémon TCG_, _Yu-Gi-Oh!_, and _Magic: The Gathering_), which yielded the most accurate results from our testing.
The transformed images are then processed using the ImageHash Python library #footnote_link("https://pypi.org/project/ImageHash/") to compute both a perceptual hash and a difference hash, which capture the visual characteristics of the cards.
These hashes allow us to measure similarity between a scanned image and reference card images.
The hashes of all known cards are stored in a special type of search tree called a BK-tree #footnote_link("https://en.wikipedia.org/wiki/BK-tree"), enabling a fast lookup of the closest matching card at runtime.
@system_architecture_diagram shows a holistic diagram of our application's architecture.

We also planned a stretch feature of a separate moderation tool, where if users report offensive/inappropriate content, it would be flagged and be ready for review in this external application.
However, we prioritized other features due to lack of time.

We have currently published production builds to Apple's App Store Connect and Google Play Console for internal testing; we have successfully gotten the app to load and function properly on consumer devices.
However, we don't plan on publishing publicly our app to the Apple App Store or Google Play Store.

One of the requirements of the capstone project is that each teammate develop one or more "rank-3" feature(s) (i.e., a substantial feature that is secondary to the core app usage) individually.
I implemented push notifications into our app (see @push_notifications_diagram for a diagram of how this was architected), alongside live updates to chats and posts.
Andy developed the wishlist feature (see @wishlist_ui), alongside searching and filtering through posts.
Thomas developed advanced card groupings (including page tags for binders and legality checks for decks), advanced card sorting and filtering (see @library_filters_ui), and card data pagination.
Jie worked on polishing the UI on iOS and web builds (see @beta_auth_ui and @final_auth_ui), but as of our final demonstration to the course staff, this was left incomplete.

#figure(
  image("../assets/system_architecture_diagram.png"),
  caption: [System Architecture Diagram],
) <system_architecture_diagram>

#figure(
  image("../assets/push_notifications_diagram.png"),
  caption: [Push Notifications Diagram],
) <push_notifications_diagram>

#figure(
  image("../assets/wishlist_ui_screenshot.png", height: 45%),
  caption: [Wishlist User Interface],
) <wishlist_ui>

#figure(
  image("../assets/library_filters_ui_screenshot.png", height: 45%),
  caption: [Library Filters User Interface],
) <library_filters_ui>

#figure(
  image("../assets/beta_authentication_ui_screenshot.png", height: 45%),
  caption: [Beta Authentication User Interface],
) <beta_auth_ui>

#figure(
  image("../assets/final_authentication_ui_screenshot.png", height: 45%),
  caption: [Final Authentication User Interface],
) <final_auth_ui>

#pagebreak(weak: true)

= Usage of Agile and Scrum
Throughout the development of _TradeTracker_, we followed an Agile methodology guided by Scrum principles.
This approach allowed our team to remain flexible and adaptive as our project evolved, particularly when balancing our external academic and personal responsibilities alongside our varying skill sets.
Agile provided us with a structure that encouraged asynchronous, continuous improvement, and collaboration while emphasizing working software over rigid planning, while Scrum gave us a template for determining what should be discussed and performed in each of our meetings.

To start, my team leveraged GitLab's issue board (see @issue_board) feature to keep track of the work we had done and each sprint's progress (i.e., the "stories").
Each of us had a pretty distinct role in the project, so determining who would take which issues/stories was pretty straightforward; I (and sometimes Thomas) would be assigned any backend issues, Thomas would be assigned to any computer vision/card scanning issues, and Jie and Andy would share frontend stories.
Near the last few weeks of the project (in the final development phase), our roles became much looser as we rushed to finish the outstanding features and our personal rank-3 features, so stories were assigned to whoever had the capacity to complete them.

#figure(
  image("../assets/issue_board.png"),
  caption: [Issue Board During the Beta Phase],
) <issue_board>

We leveraged GitLab's labels to keep track of the state of each story (i.e., "TODO", "In Progress", "Code Review", and "Done"), the "weight" field to assign "story points" to each story, which will elaborated upon later, and the "iteration" field to keep track of which "sprint" the story was to be completed in.
See @issue_details for an example of a specific issue with these details assigned.

#figure(
  image("../assets/issue_details.png"),
  caption: [Details Page of a Specific Issue],
) <issue_details>

My team met on Monday and Wednesday mornings remotely over Discord for about an hour.
At the beginning of each meeting, we would start with a short stand-up section, where each member of the team would briefly discuss what they worked on since the last meeting, what they were planning on working on until the next meeting, and any blockers they had encountered since the previous meeting.
These meetings helped everyone on the team stay up to date on the state of the project and other team members, ensuring consistent communication despite our different schedules and workloads.

We organized our development process into two-week sprints.
The capstone course is separated into three phases that consist four weeks (for the Alpha, Beta, and Final Release phases), so we allocated two sprints per phase.
At our first meeting of a new sprint, we would perform issue estimation.
Throughout the sprint, we all created new issues as needed that would be triaged at the aforementioned meeting.
Near the end of each sprint (i.e., the second Wednesday of the sprint), we performed a sprint retrospective, where we spent time discussing what went well, what went poorly, how we could improve as a team, and some general shoutouts to praise any exceptional work.
The sprint retrospective was a late addition to our sprint process, so we had only performed a few by the time development had ceased.

We began each sprint with an estimation of our currently open issues using story points.
Story points #footnote_link("https://agilealliance.org/glossary/points-estimates-in/") (also known as glossary points) are a metric for estimating how difficult a task is or how long it will take.
These meetings consisted of taking the issues in our backlog, triaging the issues (i.e., determining if the problem/feature described in the issue was already resolved or splitting the issue into multiple parts if necessary), and assigning them to the current sprint if applicable.
Moreover, we would hold a vote on the issue to determine its "weight" (GitLab's representation of story points).
We performed this vote by me counting down verbally in our meeting voice chat, and everybody sending a number using Discord's text chat right when the countdown finished.
If we all unanimously voted, we would assign the story points to the story and continue on to the next story.
Otherwise, we would have a quick discussion about possible unknowns and reasons why we voted differently.
We continued this process until we had a solid number of issues in our backlog that had story point estimates and were ready to be implemented.

My team also performed extensive code reviews as part of our Scrum practices.
I set up a rule in our GitLab project at the beginning of development that enforced that there needed to be one approval on a pull request (i.e., a set of code changes that a developer makes that is looking to be merged into the main branch of code) by another team member before the code could be merged onto the main development branch.
This ensured that we didn't accidentally merge broken code, since another team member would need to review and test the pull request (PR) before approving it to be merged.
The approval process was also aided by the continuous integration system I set up, ensuring that all backend tests/formatting and frontend formatting passed before allowing the code to merge.
Moreover, we also had a soft rule to add "acceptance criteria" to each of our PRs, giving the reviewer a small list of items to check for and test before giving their approval.
For example, whenever I submitted a pull request containing some new backend endpoints, alongside adding unit tests that ensured the behavior of said endpoints was working, I would also add some acceptance criteria for the reviewer to test out each of the endpoints themselves using the automatically generated Swagger documentation.
See @acceptance_criteria for an example of this acceptance criteria.

#figure(
  image("../assets/acceptance_criteria.png"),
  caption: [A Merged Pull Request with Acceptance Criteria in the Description],
) <acceptance_criteria>


In accordance with Agile methodologies, my team performed several user studies during the latter half of development to receive user feedback and determine which areas of the project needed the most work or should be pivoted.
Our users mostly consisted of TCG traders and collectors, while the rest of our users were individuals from different TCG-related roles, such as TCG players and card shop owners.
The feedback we received from traders and collectors is the most valuable because they comprise the largest portion of our prospective user base.
For our TCG players, we want to make sure the social aspects of our app and gameplay-related features are polished, like rulesets and card groupings.
For our card shop owners, we wanted feedback on posts, collection management, and chats; they're our "power users".
We also conducted a user study with a professional software developer to gauge their opinions and advice on our project. This was to get feedback on the frontend design that we might not have thought of otherwise, due to our relatively low amount of experience.

Most of our user studies were one-shots, with the notable exception being a TCG player whom we met up with twice---the second time being after we implemented some small features and fixed some bugs based on their prior feedback.
We had users try the app on a physical phone, taking on a "new user role" in the application.
We started them out on the "login and register" page, and we tried to have our users be in control of the app themselves.
However, when necessary, we pushed them towards areas of the app that we wanted them to interact with (i.e., the pages they hadn't explored yet).
Moreover, some of the studies were done remotely over online platforms like Discord, so having the users get their hands on the app was difficult.
In such situations, we screen-shared our own phones or an emulator view and asked the users what they'd like to tap and type.

Across all of our user studies near the final phase of development, the general impression of the app was positive.
Users voiced that the app has a clean layout, a smooth and easy navigation, and a good potential for collectors and traders to coexist.
When asked to rate the application on a scale of 1 to 5 (with 1 being terrible and 5 being excellent), users gave the app a rating of 3.5 to 4.5, and most users rated the ease of use between 4 and 5 on average.
This helps to show that we have a well-understood and easy-to-navigate interface, despite the fact that there are a few UI/UX issues that could have been touched upon.
For an example of some feedback we received and acted upon due to the user review, see @user_study_ui; before the user studies, we had just typed in the internal user IDs of the users we wanted to create chats with when testing, without.
This interface is not helpful for an end-user, as these internal IDs are not exposed to users---users likely expect to find other users by their name, not some arbitrary number.
Thus, we prioritized fixing this issue, and ended up with a system where you could scroll and search through users by their name.
Ultimately, this user feedback helped us identify and fix immediate issues to make our app more targeted and helpful to our prospective users.

#figure(
  table(
    columns: 2,
    inset: 0.25in,
    image("../assets/user_study_ui_screenshot_before.png", height: 50%),
    image("../assets/user_study_ui_screenshot_after.png", height: 50%),
  ),
  caption: [Chat Creation UI before and after the User Studies]
) <user_study_ui>

One of the final Scrum activities my team performed was sprint retrospectives.
In the following meeting after a sprint ended, I would create a Google Doc with the following headings: "What went well during the last sprint?", "What went poorly during the last sprint?", "What could we improve on as a team?", and "Shoutouts".
Then, I would set a timer for about 5 minutes, and we would all write a few bullet points about our thoughts on each heading.
The final heading, "Shoutouts", was reserved for giving recognition to other teammates for especially great work during the sprint.
Once the timer expired, we would take turns reading out what we wrote about under each of the headings, and others would chime in if they agreed or had any thoughts on the feedback.

These sprint reviews were very helpful for gauging the opinions of my teammates and the state/morale of the team as a whole.
They gave us actionable feedback on what we were struggling with and allowed us to discuss how we could address these issues.
For example, a common piece of feedback we almost unanimously shared was that we weren't communicating enough.
We addressed this by having everyone make an effort to give progress updates asynchronously over Discord chat on days that we weren't meeting up.
This communication issue likely would not have been brought to light or resolved if not for these sprint retrospective activities.

In summary, this adapted Agile/Scrum structure worked well for our team overall.
It provided a consistent rhythm for development while remaining flexible enough to accommodate external constraints, such as academic deadlines and the summer development pause.
The iterative cycle of planning, development, and reflection kept the project organized, motivated us to deliver tangible progress every sprint, and allowed us to look back on our recent progress and adapt our development processes to be more efficient and manageable.
However, we also encountered challenges, particularly around accurately coordinating schedules and maintaining our typical development cadence during busier academic weeks.
Despite these hurdles, Agile and Scrum proved to be valuable frameworks for maintaining momentum and focus throughout the project.

#pagebreak(weak: true)

= Reflection
Overall, I feel our project was successful, demonstrating both solid technical implementation and meaningful collaboration.
We successfully created a full-stack application that has many valuable features, such as card scanning, collection management, and user interaction.
I was also generally pleased with our usage of Agile and Scrum methodologies.
While sometimes it did feel like I was forcing my teammates to perform these seemingly "time-wasting" activities, I also believe it helped keep our team on track despite some hiccups in development.
For example, doing stand-up at the beginning of every meeting helped "break the ice" a bit, and spawned discussion regarding what parts of the application we needed to prioritize and what assignments in class we needed to keep up to date with.
It also helped many of us stay on top of the work that we were doing.
There were several times where one team member (myself included) would report something along the lines of, "I actually didn't get anything done since our last meeting", which was not only a cause for self-reflection in the team member, but also caused some implicit peer-pressure to keep the development cadence up.
Sprint estimation helped us keep a model of how difficult certain tasks would be and allowed us to allocate tasks between members much more fairly.
This wasn't as directly beneficial to our development compared to some of the other Scrum practices, but it was a helpful estimate for how difficult a task was and provided a pseudo-justification for why a certain issue may be blocking a developer for multiple days.
Sprint retrospectives gave us a specific time to be candid with one another and restructure how we worked together as a team.
As I mentioned before, this allowed us to positively reconfigure how we communicated with one another.

Despite my general positivity, our project had much more potential for features and UI polish.
Unfortunately, I ended up taking on an inordinate amount of work on the project, and one of my teammates became much less active on the project during the latter half of development, which hampered our progress and required my other two teammates and me to pick up the slack, resulting in us accomplishing less overall.
This teammate also didn't finish their rank-3 feature, which harmed the overall state of our project.
For example, one of our prospective features was "event posts", where tournament owners or card shop owners could make posts tagged with a time and location describing the event that they are hosting (including what card games/rulesets were being played, prizes, etc.), but this was scrapped due to our limited development bandwidth.
I also regret not working on the project over the summer (though I think I have a good excuse, as I was working as a full-time software engineer), as that would've given us a good boost going into our second semester of development, where time was much more valuable than the relatively lax summer days.

Overall, I believe this experience with Agile and Scrum practices was fairly accurate to my industry experience, despite the aforementioned setbacks; the good parts of using Agile and Scrum were certainly made evident.
I modeled our usage of these practices on my experience as a software engineer intern and part-time employee at Lucid Software, which is somewhat well-known for actively incorporating Agile and Scrum into their practices.

#pagebreak(weak: true)

= Conclusion
The development of TradeTracker served as a technical and collaborative learning experience that demonstrated the value of Agile methodologies in real-world software projects.
By embracing Scrum principles such as sprint planning, retrospectives, and continuous integration of user feedback, our team maintained a structured yet flexible workflow that enabled consistent progress, even amid the challenges of differing schedules and workloads.
These practices helped us refine our communication, adapt to user feedback, and maintain a shared sense of accountability throughout the project's lifecycle.

From a technical perspective, TradeTracker successfully integrates a full-stack architecture that combines FastAPI, SQLite, and Expo (React Native) into a cohesive platform for managing and trading collectible cards.
The inclusion of features like card scanning, collection management, and user interaction demonstrates the potential of the application to provide meaningful value to TCG enthusiasts.
While some stretch features, such as event posts and moderation tools, were not fully realized due to time constraints, the foundation laid by our design and development process provides a strong base for future improvements and expansions.

Beyond the technical deliverables, this project highlighted the importance of iterative development and open communication in team-based environments.
The feedback gathered from user studies reinforced the utility and appeal of the application while also identifying areas for further enhancement.
Ultimately, TradeTracker not only met its primary objectives of facilitating collection management and social interaction within the TCG community but also served as a practical demonstration of how Agile practices can transform an academic project into a professional-grade product.

In conclusion, this experience has deepened my understanding of both software engineering principles and collaborative project management.
It reinforced that successful software development is about communication, adaptability, and delivering real value to users.
I am proud of what our team accomplished and am confident that the lessons learned from TradeTracker will carry forward into future professional endeavors.
