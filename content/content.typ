#let footnote_link(url) = footnote(link(url), numbering: "[1]")
#show footnote.entry: it => {
  let loc = it.note.location()
  numbering(
    "1. ",
    ..counter(footnote).at(loc),
  )
  it.note.body
}
#show cite: it => [
  #super[#it]
]

= Introduction and Background

== Introduction to FreezeTag

FreezeTag is a free and open-source, self-hosted image management application developed for the University of Utah's Kahlert School of Computing senior capstone project during the Fall 2025 and Spring 2026 semesters by Ethan Collier, Brayden Jonsson, Max Petersen, and Sathya Tadinada (the author of this thesis). FreezeTag is designed to give photographers, businesses, and hobbyists a way to store, organize, and retrieve their photos without depending on a cloud-based service. The application runs on hardware the user already owns, exposes its interface through a web browser, and allows users to attach custom tags and metadata to their images so that specific photos can be found quickly even across very large collections.

A core problem FreezeTag addresses is that existing image management solutions force users to choose between convenience and control. Services like Google Photos @google_photos and Apple Photos @apple_photos are easy to use and widely accessible, but they store data on remote servers owned by third parties, charge recurring fees that grow with the size of a user's collection, and offer little to no ability to customize how the software behaves. On the other end of the spectrum, tools like DigiKam @digikam provide local storage and more configurability, but require the application to be installed on every device the user wants to access their photos from, and setting up networked access across multiple machines is a cumbersome manual process. Neither category of solution works well for the kinds of users FreezeTag targets. Freelance photographers benefit from the tagging system for organizing work by client or event, and from the guarantee that the original image format is always preserved and recoverable. Small businesses gain the ability to operate on air-gapped or otherwise isolated infrastructure for compliance or security reasons, and to integrate FreezeTag directly through its API into automated workflows without depending on a third-party service's uptime or pricing. Technically inclined hobbyists who already run their own network-attached storage devices get software that fits naturally into that infrastructure without requiring any accounts, subscriptions, or external services. Across all of these use cases, self-hosting also means the operator controls uptime entirely, since there is no third-party outage that can take access to a photo library offline.

A second problem is how most image management tools handle organization and search. The dominant approach across nearly every major solution is folder-based organization, where photos are sorted into a hierarchy of directories, often by date or by some manually maintained folder structure. Google Photos organizes images chronologically and offers an AI-powered search that can recognize objects and faces, but it does not give users a way to define and apply their own categorical labels in any structured way. DigiKam supports tags in principle, but the tagging system is secondary to its folder-based model and is not designed around search as a primary use case. Apple Photos has albums, which function similarly to folders, and its search is limited to metadata that the app itself recognizes automatically. In general, none of these tools treat user-defined tags as a first-class feature, meaning that a photographer who wants to label images by client name, usage rights, subject matter, and shooting location simultaneously has no good way to do that and then query across all of those dimensions at once.

FreezeTag treats tags as the primary organizational unit of the application. Rather than asking users to maintain a folder hierarchy, FreezeTag allows any number of tags to be attached to any image, and those tags are stored in a searchable database alongside automatically extracted EXIF metadata. A user can apply tags like "client:Acme", "location:SaltLake", and "format:print" to a batch of images at upload time, and then later retrieve exactly that subset of their collection by searching across any combination of those tags. This model scales much more naturally to large or complex libraries than folder structures do, because a single image can belong to multiple logical groupings without needing to be duplicated or moved across directories.

FreezeTag addresses the self-hosting problem by running as a web server on hardware the user provides. Because the interface is entirely browser-based, any device on the same network can connect to a single FreezeTag instance without any software installation on the client side. Photos are stored locally and deployment is handled through Docker Compose @docker_compose, which means getting a FreezeTag instance running requires only a single command, and the environment is consistent regardless of what operating system the host machine is running. FreezeTag is planned for release under the MIT open-source license following the conclusion of the capstone sequence, meaning it will be free to use, modify, and distribute without restriction. Beyond the core tagging and gallery functionality, FreezeTag is also extensible through a Python-based plugin system, which will be described in more detail later in this chapter.

== Team Formation

FreezeTag was built by four developers over approximately two semesters of active development time, with each developer spending roughly ten hours per week on the project. Development began in the Fall 2025 semester and concluded near the end of the Spring 2026 semester. We used GitLab @gitlab for hosting our code repository, issue board, and contribution guidelines. The team was split into two frontend engineers and two backend engineers, with each member owning a clearly defined area of the codebase from the start of the project. The developers on the project were:
- Ethan Collier, Backend Feature Engineer
- Brayden Jonsson, Frontend Architecture Engineer
- Max Petersen, Backend Architecture Engineer
- Sathya Tadinada (the author of this thesis), Frontend Interface Engineer
The frontend and backend teams each owned distinct areas of the codebase throughout development. On the frontend side, Brayden was responsible for lower-level concerns such as parsing and handling API responses, managing frontend state, and handling authentication on the client side, while I was responsible for the visual design and CSS implementation of all user-facing pages. On the backend side, Ethan owned the API endpoints and the primary user-facing features such as image storage and metadata parsing, while Max was responsible for dependency management, the plugin environment, and deployment infrastructure. In practice there was some natural overlap, particularly around API contract decisions between the frontend and backend teams, but the division held well throughout both semesters. We used an Agile development process organized around two-week sprints, with standups, code reviews, and sprint retrospectives throughout both semesters of development, which is covered in detail in the Software Methodologies and Techniques chapter.

== Tech Stack and Architecture

At a high level, FreezeTag consists of two servers that communicate with each other and with a set of Python plugins. The Go @golang backend serves as the core of the application, handling API requests from the frontend, reading and writing image metadata to a SQLite @sqlite database, invoking ImageMagick @imagemagick for image format conversion and metadata parsing, and managing the lifecycle of Python plugins. The Next.js @nextjs frontend communicates with the backend over HTTPS and is responsible for all user interaction. The Python plugin layer sits below the backend and receives image and metadata payloads through a pipeline, returning processed results that the backend then stores or acts on. The entire system is deployed and orchestrated using Docker Compose, which allows the frontend server, backend server, and plugin environment to be started together with a single command. @system_architecture shows the overall architecture of the system.

The backend server is written in Go, which we chose for its performance, strong concurrency support, and straightforward deployment characteristics. Go's built-in support for goroutines made it a natural fit for a server that needs to handle plugin execution concurrently alongside serving API requests. The backend uses the Gin @gin web framework for routing and middleware, which also automatically generates Swagger documentation for all API endpoints through Gin-Swagger. This was useful during development because it gave the frontend team an always-current reference for the available endpoints without needing to read through backend source code directly.

The backend uses SQLite as its database, which stores all image metadata, tag associations, user information, and plugin configuration. SQLite was a practical choice for a self-hosted application because it requires no separate database server process and stores the entire database as a single file on disk, making backups and migrations straightforward for non-technical users. Image format conversion and EXIF metadata extraction are handled through ImageMagick, a widely used open-source image processing library that supports an extensive range of file formats. On upload, ImageMagick extracts embedded metadata fields such as timestamps, GPS coordinates, and camera model, and also generates compressed thumbnail versions of images in the WebP @webp format for efficient display in the gallery interface.

The plugin environment is managed using uv @uv, a fast Python package manager, and each plugin runs in its own isolated virtual environment to prevent dependency conflicts between plugins. Communication between the Go backend and the Python plugins happens over a loopback port using a custom REST protocol, with the backend acting as the orchestrator that decides when to invoke a given plugin and what data to pass to it. Plugins can also read from a shared SQLite table that the backend exposes to them in read-only mode, which allows plugins to make decisions based on existing tags and metadata without needing a separate API call.

The frontend is built with Next.js, a React-based framework that handles both server-side rendering and static asset serving. We used pnpm @pnpm as the package manager for the frontend project, and Jest @jest for unit testing. Image uploads are handled through react-dropzone @react_dropzone, which provides the drag-and-drop upload interface, and all communication with the backend API is done with a standard fetch API via undici @undici.

The plugin system is one of the most distinctive aspects of FreezeTag's architecture. Rather than building every possible image processing feature directly into the backend, we designed a plugin interface that allows Python scripts to hook into the image upload pipeline and contribute new tags, captions, or other metadata based on the content of the uploaded image. Plugins are listed and managed through the plugin management page in the frontend, where users can enable or disable individual plugins and view their version and available hooks. @plugin_interface shows the plugin management interface. The first-party plugins that shipped with FreezeTag by the end of development were:
- Face Recognition: detects and identifies faces in uploaded images using a local machine learning model, and automatically applies name-based tags to images containing recognized individuals.
- Google Gemini Tagger: sends uploaded images to Google's Gemini API @gemini_api and uses the model's vision capabilities to generate descriptive tags automatically, providing a cloud-assisted tagging option for users who are comfortable with that tradeoff.
- ML Tagger: runs a local machine learning model to classify image content and suggest tags without sending any data to an external service, making it suitable for users who want automated tagging with full data locality.
- RAM Tagger: a lightweight local tagger that operates with a smaller memory footprint than the full ML Tagger, intended for users running FreezeTag on hardware with limited RAM.
Each team member was also responsible for implementing at least one substantial Rank 3 feature independently. My two Rank 3 features were adding UI for displaying photo locations on an interactive map, and custom theme importing functionality. These are covered in detail in the Individual Contributions chapter.

#figure(
  image("../assets/System Architecture.png"),
  caption: [System Architecture Diagram],
) <system_architecture>

// TODO: Insert plugin interface screenshot here
#figure(
  image("../assets/System Architecture.png"),
  caption: [Plugin Management Interface],
) <plugin_interface>

#pagebreak(weak: true)

= Individual Contributions

== Role in the Project

As the frontend interface engineer on FreezeTag, my primary responsibility was the visual design and CSS implementation of every user-facing page in the application. The frontend team was divided between two distinct roles. Brayden, as the frontend architecture engineer, was responsible for the lower-level concerns of the frontend, such as managing API communication, handling authentication state, and structuring how data flowed through the application. My role sat on top of that foundation, taking the data and API integrations Brayden built and turning them into the actual interface that users see and interact with. In practice, the two roles required close and ongoing coordination throughout both semesters, since good UI components need real data behind them and data-handling code needs a UI surface to be meaningful. The pages I did primary development on were the overall application UX, the gallery page, the image detail view, the tags management page, the settings page, and the image detail sidebar. My two Rank 3 features were adding UI for displaying photo locations on an interactive map within the image detail view, and custom theme importing functionality accessible through the settings page.

== Frontend Interface Implementation

The gallery page is the primary view of the application and the page that users land on after logging in. It displays all uploaded images in a responsive masonry-style grid, with each image rendered as a WebP thumbnail generated by the backend at upload time. The top of the page contains a search bar that accepts a custom query syntax, with example queries shown as hints below the bar to help new users understand how to construct searches. Alongside the search bar, there are three controls: a Tags dropdown, a Sort dropdown, and a Select button.

[PLACEHOLDER: Gallery page screenshot showing the Tags dropdown open (Image 1)]

The Tags dropdown allows users to filter the gallery by tag using an intersection model. When a user opens the dropdown, it displays all tags currently present in the library along with a count of how many images carry each tag. Selecting a tag filters the gallery to show only images with that tag, and the dropdown then updates to show only the tags that also appear on those filtered images. This means a user can progressively narrow their search by selecting multiple tags in sequence, and at each step the dropdown only presents tags that are actually relevant to the current filtered set rather than the full list. This behavior directly reflects FreezeTag's tag-first philosophy, where combinations of tags are the primary way users navigate their library.

[PLACEHOLDER: Gallery page screenshot showing the Sort dropdown open (Image 2)]

The Sort dropdown allows users to sort the gallery by either date created (the date the photo was taken, extracted from EXIF metadata) or date added (the date the image was uploaded to FreezeTag), and to order the results either newest first or oldest first. These two sort dimensions are distinct and both useful: a user who just uploaded a batch of old scanned photos would want to sort by date added to find what they just uploaded, while a user browsing their collection chronologically would want to sort by date created.

The Select button switches the gallery into a multi-selection mode. In this mode, a tag panel appears on the right side of the screen listing all tags in the library, and users can check individual images in the gallery to build a selection. Once a selection is made, users can apply tags to all selected images at once, run plugins against the selection, or delete the selected images. This workflow is particularly important for users who upload large batches of photos at once and want to apply a shared set of tags across all of them without having to open each image individually.

[PLACEHOLDER: Gallery page screenshot showing Select mode with the tag panel visible (Image 3)]

Clicking any image in the gallery opens the image detail view, which is a fullscreen overlay showing the image at full resolution alongside a collapsible metadata sidebar. The image viewer supports zoom controls at 1x and 2x magnification, and left and right arrow buttons allow the user to navigate to the previous or next image in the current gallery view without closing the overlay. The metadata sidebar displays all EXIF data extracted from the image at upload time, including resolution, date taken, date uploaded, GPS coordinates, and camera model. Below the EXIF fields is a scrollable tags section where users can view, remove, and add tags on a per-image basis. The sidebar can be hidden entirely if the user wants to focus on the image itself. Below the tags section in the sidebar is where the interactive map is displayed as part of my first Rank 3 feature, which is described in the next section.

[PLACEHOLDER: PreviewWindow screenshot (Image 4)]

The upload page allows users to add new images to their FreezeTag library. Users can either click an "Upload Images" button to open a file picker or drag and drop images directly onto the button. Once images are staged for upload, they appear as thumbnails in the main area of the page, and the tag panel from the gallery's Select mode appears on the right side of the screen. This allows users to select from existing tags or create new ones and apply them to the entire batch before finalizing the upload. The Select All and Deselect All buttons at the top make it easy to apply a set of tags to every image in the batch at once.

[PLACEHOLDER: Upload page screenshot (Image 5)]

The tags management page provides a dedicated interface for managing all tags stored across the entire library. It displays a paginated list of every tag in the system alongside a count of how many images currently carry that tag. Users can search across all tags using a fuzzy search bar at the top of the page, which makes it easy to find a specific tag in a large library. Each tag row has a navigation arrow that filters the gallery to show only images with that tag, and a delete button that removes the tag from all images. Users can also select multiple tags using the checkboxes and mass-delete them in a single action, which is useful when a plugin has generated a large number of unwanted or duplicate tags.

[PLACEHOLDER: Insert the tags management page screenshot (Image 6)]

The settings page is organized into three sections: Profile, Preferences, and Security. The Profile section allows users to upload and change their profile picture, which appears in the bottom left corner of the sidebar throughout the application. The Preferences section contains two settings: a theme selector and a unit toggle. The theme selector currently allows users to choose from a set of built-in Catppuccin @catppuccin themes, which is a popular open-source color scheme with a dedicated following in the self-hosted software community. The unit toggle switches between metric and imperial units, which affects how distances are displayed, particularly in the context of the map feature. The Security section contains a password change form.

[PLACEHOLDER: Insert the settings page screenshot (Image 7)]

== Rank 3 Features

My two Rank 3 features were the interactive map view within the image detail sidebar, and custom theme importing through the settings page.

The map feature is currently in progress and will be integrated directly into the image detail sidebar, appearing below the tags section when an image has GPS coordinate data available. The design intent is similar to how Google Photos surfaces a small embedded map within its photo detail view, showing the approximate location where the photo was taken as a pin on an interactive map the user can pan and zoom. The map will be rendered using Leaflet @leaflet with OpenStreetMap @openstreetmap tile data, both of which are open-source and do not require an API key, which is consistent with FreezeTag's goal of being fully self-hostable without requiring accounts or paid services. Because the GPS coordinates are already extracted from EXIF data at upload time and stored in the database, the map component only needs to read those coordinates and pass them to Leaflet to render the pin.

[PLACEHOLDER: Insert a screenshot of the map feature once complete]

The custom theme importing feature is also currently in progress and will be accessible through the Preferences section of the settings page. The goal is to allow users to upload a configuration file specifying a set of Catppuccin CSS variable names and the color values they want to assign to each one, effectively letting them define a completely custom color palette for their FreezeTag instance. This approach builds on the Catppuccin theming system already in place in the application, so users who are familiar with Catppuccin's variable naming conventions can customize their instance without needing to write any CSS directly. There is also potential to extend this with a color picker interface or a plain text input for pasting in values, which would lower the barrier for users who are not familiar with the file format.

[PLACEHOLDER: Insert a screenshot of the theme importing UI once complete]

#pagebreak(weak: true)

= Software Methodologies and Techniques

== Agile and Development Process

From the beginning of the project, our team adopted an Agile @agile development process. Agile was a natural fit for FreezeTag because the application had a large number of features that were interdependent on each other, meaning that the specific implementation details of one part of the system frequently had implications for how another part needed to be built. Rather than trying to plan every detail upfront and stick to a rigid schedule, Agile gave us the flexibility to respond to those kinds of discoveries as they came up during development without derailing the project.

Development was divided by the capstone course into three major phases: Alpha, Beta, and Release, each roughly four weeks long. We used these phase boundaries as natural checkpoints to reflect on what had been completed and make deliberate decisions about what to prioritize in the next phase. At the end of each phase, the team would review the state of the issue board, assess which features had shipped and which had not, and decide together whether unfinished items should be carried forward as priorities or pushed to the backlog in favor of other work. This gave us a structured moment to recalibrate without needing to hold separate retrospective meetings throughout the phase.

Within each phase, work was tracked using GitLab's @gitlab issue board. We created issues for every feature, bug, and task across both the frontend and backend, and used a set of labels to organize them. Phase labels (Alpha, Beta, Release) indicated which phase an issue was targeted for. Domain labels (Frontend, Backend) indicated which side of the codebase the issue belonged to. Type labels (Bug, Feature) described the nature of the work. Each issue also carried a state label (Backlog, To Do, In Progress, Done) that was updated as work progressed, giving the whole team a clear and current picture of where development stood at any given time.

[PLACEHOLDER: Insert a screenshot of the GitLab issue board showing the label columns and a spread of issues across states]

[PLACEHOLDER: Insert a screenshot of a specific issue detail page showing its labels, assignee, and description]

== Meetings and Communication

Our team met three times per week throughout most of both semesters. The Friday staff meeting with the course instructor was held in person. Outside of that, we met remotely on Monday evenings to align on goals for the week ahead, and again on Wednesday or Thursday evenings to review progress, work through any blockers, and prepare for the Friday meeting. Most communication between meetings happened asynchronously over Discord, which gave us the flexibility to work on our own schedules while still staying coordinated. Scheduling was not always straightforward given that four students have very different weekly commitments, so we kept the number of required meetings small and relied on the asynchronous channel to fill in the gaps.

== Tools and Infrastructure

Before any application code was written, the team prioritized setting up a CI pipeline that would automatically enforce quality standards on every merge request targeting the main branch. Max was the primary person responsible for building and maintaining this system. Every merge request was required to pass three automated checks before it was eligible for human review: a format check, a lint check, and a unit test run.

The format check required all code to be formatted with the standard tool for its language. We used Prettier @prettier for the frontend and gofmt @gofmt for the backend. Consistent formatting across the codebase reduces unnecessary noise in diffs and makes the repository history easier to follow when multiple people are working in overlapping areas.

The lint check required all code to pass the appropriate linter with no warnings or errors. We used ESLint @eslint for the frontend and golangci-lint @golangci_lint for the backend. Both tools were configured with their default rulesets as the baseline, with a small number of additional rules added on top to suit our specific needs.

The unit test check required all existing tests to pass and enforced a minimum code coverage threshold of 80% across both the frontend and backend. Frontend visual components were largely exempt from the coverage requirement since they are primarily layout and styling code that is better verified by hand than by automated tests. By the end of development, the frontend had reached approximately 95% code coverage and the backend approximately 85%, both comfortably above the minimum.

[PLACEHOLDER: Insert a screenshot of a GitLab merge request showing the CI pipeline status and the reviewer approval section]

== Code Reviews

In addition to the automated pipeline checks, every merge request required a manual review and approval from at least one designated primary reviewer before it could be merged. The author of each merge request was responsible for assigning a primary reviewer with relevant knowledge of the area of the codebase being changed. Frontend merge requests were reviewed by whichever frontend engineer had not authored the request: if I submitted a merge request, Brayden would review it, and if Brayden submitted one, I would review it. The same pattern applied on the backend between Ethan and Max. Any team member could also leave a blocking review if they found a significant issue regardless of domain, though this was rare in practice. The combination of automated checks and mandatory peer review meant that code reaching the main branch had passed both machine-enforced quality gates and a human assessment before being integrated.

== Documentation

Our team's general approach to documentation favored writing clear, readable code over heavy inline commenting. The main structured exception to this was the backend API layer, where all endpoints were annotated with comments specifically to enable automatic Swagger documentation generation through Gin-Swagger. This gave the frontend team a reliable, always-current reference for every available endpoint without needing to read through backend source code directly. At the project level, we maintained documentation in READMEs throughout the repository. This was done with an eye toward FreezeTag's planned release as an open-source project under the MIT license following the conclusion of the capstone sequence in the summer of 2026, at which point external contributors will need enough documentation to understand and work with the system without guidance from the original team.

== User Studies and Feedback

Our team participated in the formal user studies required by the capstone course. Beyond those, we also gathered informal feedback throughout development by showing in-progress features to peers and collecting reactions in the moment. This kind of lightweight, continuous feedback helped us catch usability issues early, before they became deeply embedded in the design. Because we used FreezeTag ourselves as part of the development process, we also gave each other ongoing feedback on UI decisions as new interface elements landed, which helped the team converge on design choices efficiently without needing dedicated meetings for every decision.

#pagebreak(weak: true)

= Reflection and Analysis

== Successes and Challenges

Overall, I consider FreezeTag to be a successful project, both as a piece of software and as a team experience. The thing I am most proud of is how seriously all four of us took it from start to finish. FreezeTag was not just a class assignment that we put in the minimum effort to complete; it was something all four of us were genuinely invested in building, and I think the final product reflects that. We started with a clear project vision in Fall 2025 and executed on that same vision through Spring 2026 without significant pivots or course corrections. The core idea, a self-hosted, tag-first image management application with an extensible plugin model, was the idea we shipped. That kind of consistency from initial concept to finished product is not something every capstone team achieves, and it speaks to how well-defined our goals were from the beginning.

From a purely technical standpoint, what I am proudest of is how close FreezeTag came to feature parity with established commercial solutions like Google Photos and Apple Photos. It is not a perfect comparison in every dimension, but the features we do have work well, and the combination of tag-based search with a custom plugin model is something that no major image management product currently offers. That makes FreezeTag genuinely novel in its category, which is not something I expected to be able to say about a student capstone project.

On a personal level, this project pushed me well outside of my comfort zone. Coming into capstone, I had very limited experience with React and Next.js, and almost no formal background in UI/UX design. Taking on the frontend interface role meant I was responsible for the visual design and implementation of every page in the application, which was a steep learning curve early on. By the end of the project I felt genuinely competent in those skills in a way I did not at the start, and I can see myself applying them directly in a professional context.

The challenges we ran into were mostly technical rather than interpersonal. The most recurring difficulty was infrastructure compatibility: versioning conflicts between libraries, packages that lacked support for the specific functionality we needed, and interactions between different parts of the stack that did not behave as expected. These kinds of issues tend to be time-consuming in a way that is hard to plan for because they are often invisible until you are already deep into an implementation. Two specific areas that took significantly longer than our original timeline had estimated were user authentication and the jobs tracking system for photo uploads and plugin runs. Both turned out to be more architecturally involved than we had anticipated when drafting the design document, and accommodating them required some reshuffling of priorities in the surrounding weeks.

Some features were also scoped down or deferred over the course of development. A plugin marketplace, which would have allowed users to discover and install community plugins directly from within the application, was pushed out of scope in favor of keeping the core experience polished. The location map feature, which was originally envisioned as a fully interactive embedded map in the image detail sidebar, ended up being implemented as a toggleable native UI component due to the complexity of integrating an interactive Leaflet map cleanly into the sidebar layout at that stage of development. These were deliberate tradeoffs rather than failures; the plugin system's architecture is flexible enough that a marketplace could be added post-capstone without requiring changes to the core application, and the map component achieves the core goal of surfacing location data from image metadata in a way that is useful to the user.

There were occasional disagreements on frontend design decisions, as is natural when multiple people have opinions on subjective visual choices. In most cases we reached a consensus quickly through discussion, and when we could not, we asked external users for their preference, which gave us an objective enough tiebreaker to move forward without much friction.

For the custom theme importing feature, the main challenge was designing an import format that was flexible enough to be genuinely useful while remaining simple enough that non-technical users could work with it. Building on Catppuccin's existing CSS variable naming conventions gave us a reasonable foundation, since a meaningful portion of the self-hosted software community is already familiar with that system, but determining the right level of abstraction for the import file format required several iterations.

== Future Directions

The most immediate future direction for FreezeTag is performance at larger scale. The Go backend served us well during development and handles concurrency cleanly, but now that we have a solid understanding of what the application's data access patterns actually look like in practice, there is a reasonable case for eventually rebuilding the backend in Rust for a more production-ready implementation. Rust's memory model and performance characteristics would make it better suited to handling very large photo libraries or multi-user deployments without the overhead that a garbage-collected language introduces.

On the frontend, the priority would be continued feature development and polish to close the remaining gap with commercial solutions. There are parts of the interface that work correctly but would benefit from more refinement, and there are features that were scoped out during the capstone that would meaningfully improve the user experience if added.

The plugin ecosystem is probably the area with the most long-term potential. Right now, discovering and installing plugins requires some manual effort on the user's part. A plugin marketplace built into the application itself, where users could browse, install, and update plugins without leaving FreezeTag, would make the extensibility of the platform much more accessible to non-technical users. Given the flexibility of the existing plugin architecture, building a marketplace on top of it should be relatively straightforward compared to the work that went into building the plugin system itself.

FreezeTag is also planned to be released under the MIT open-source license following the conclusion of the capstone sequence in the summer of 2026. That transition will bring its own set of priorities around documentation, contributor onboarding, and maintaining a stable public API for the plugin system, all of which the team has been building toward throughout development.

== Lessons Learned

If I were starting this project over, the most significant technical change I would make on the frontend would be to move away from Next.js toward a more conventional Node.js server setup. Next.js introduced a recurring set of friction points throughout development, particularly around the distinction between client and server components and various React hydration issues that were difficult to diagnose and fix. Some of these may have been React issues rather than Next.js specifically, but the framework added enough complexity to the development experience that a simpler server setup would likely have let us move faster and with less confusion. This is not a critique of Next.js as a technology in general, it is well suited to many use cases, but for an application like FreezeTag where the interface is relatively stateful and the server-side rendering model does not provide much benefit, the tradeoffs were not in our favor.

I would also have started active development earlier in the Fall 2025 semester. A significant portion of that semester was spent on planning, design, and evaluating options, which was valuable but could have been compressed given how clear the project vision was from the start. Starting earlier would not necessarily have changed what we built, but it likely would have given us more time to add features and polish in the final stretch.

On the design side specifically, I would have sought out formal UI/UX guidance and design system references much earlier in the process. A large part of the visual design work ended up requiring iteration and backtracking, largely because I was figuring out design principles and patterns as I went rather than starting from a well-defined design language. Consulting with more experienced designers or studying established design systems earlier would have saved time and produced a more cohesive result from the start. That said, the experience of working through those problems without a safety net taught me more about interface design than I would have learned in a more guided context, and I came out of it with a much stronger instinct for UI decisions than I had going in.

More broadly, this project reinforced a lot of the ideas introduced in earlier software development coursework at the University of Utah around effective team collaboration, version control practices, and the value of building in small, reviewable increments. The difference is that in a capstone context those ideas are no longer abstract; you feel the consequences of following or ignoring them directly in the quality and pace of your own work. FreezeTag is the most complete and technically involved piece of software I have built as a student, and the lessons from building it are ones I expect to carry into my career.

#pagebreak(weak: true)

= Conclusion



#pagebreak(weak: true)