# Main Application

# Topbar
1. the title is too far to the left. also change it to Minerva Machine Safety. 
2. centre the search bar, make the shortbut not apple and make it work. 
3. make the light/dark selector a sub menu. in the avatar menu. 
4. need to improve the connection and processing. they can probs be merged and be a little lower key. we should probs create a processing page for the users to see whats going on. 

## Sidebar
1. when the user selectes expanded, the sidebar will not cover the main content. It can cover the main content when in auto collapse
2. Move the recent projects to a sub menu under projects. have an arrow to expand or collapse the menu. show a few recent projects, then have a more button that navigates to all projects page. 

## Photos Page
1. the photo selected icon, when selected has an extra circle around it. expand the sleected icon so its the same size as the outside circle. 
2. the gray cicle behind is slitght bigger than the select icons
3. i want the day heading to include site names of that day after for exmaple:
    "**Monday** Site Name + 2 More -v " 
4. more than one day can go on a photo row. a new day shouldnt start on a new row unless the row is full. 
5. remove search bar from page. use top serach bar.
6. need to have a filters area at the top. maybe a button that expands a little area. have filters like who took the photo, projefts, sites, machien types tags ect. 
7. the photos page has two scroll bars. nee dto remove the outside one.
8. we could add small icons to the bottom of each photo. one with the number of tags, then one with a little verify shielf badge if all the ai tags have been accpeted/rejected. 

### Photos details Modal
1. Issues 
   1. Error: Chat GET API error: 401 {}
    at createConsoleError (http://localhost:3000/_next/static/chunks/node_modules_next_dist_client_8f19e6fb._.js:882:71)
    at handleConsoleError (http://localhost:3000/_next/static/chunks/node_modules_next_dist_client_8f19e6fb._.js:1058:54)
    at console.error (http://localhost:3000/_next/static/chunks/node_modules_next_dist_client_8f19e6fb._.js:1223:57)
    at PhotoChat.useCallback[fetchMessages] (http://localhost:3000/_next/static/chunks/components_photos_5472f388._.js:5251:29)
    Error: Unauthorized
    at PhotoChat.useCallback[fetchMessages] (http://localhost:3000/_next/static/chunks/components_photos_5472f388._.js:5252:27)

2. maybe a feature that when you open a photo for the first time a little box opens up down the button with the questions 'what do you see' and the user can quickly add details, that will be porccessed by the ai and added to the phto info. 
3. clicking outside the photo on the blurred area closed it. 

## Search. 
1. seach shouldnt be its own page. it should be accessed from the top bar. when clicked, it should pop down a menu that has recent seraches, then maybe suggested projects or sites
2. search should be context aware, it should know what page its on a adjust accordinly. like if someone types "conveyor' it could suggest conveyors from the active project first, then have a line to show conveyors in a differnec project? - needs refinement...

## Albums
1. remove the Smart from the name, just go with albums

## Upload phoots
1. the photos upload modal has two X buttons to close it. 
2. i want to create a smart uploading work flow, where the app will pull the meta data and say suggest either an exisitng project or site or both based on the location data. if nothing exisits, it could say looks like you where are this site, what to create it? want start a project?

## UI issues
1. When we go to a 404 page, and are then redirected back, the ui changes from dark to light, momentary then back to dark. 

## User profile, managemnt page
1. the user profile page is full of mock data. we need to reveiew this, the organisation settings, the org admin (not to be consufed with the platfomr admin). tools and set up. 

# Platform Admin Consol
## UI
1. Dark mode is broken. i like the look of the admin platform, how it looks differnent to the main app. but the dark mode dosent work here.

## Orgs and Users
1. Conslidate the orgs and users onto one page. this could be done with tabs? not sure what the best approach is.

## Feedback
1. is broken 
   1. Error: Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: undefined. You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.

Check the render method of `PlatformFeedbackPage`.
    at createFiberFromTypeAndProps (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:4928:32)
    at createFiberFromElement (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:4939:16)
    at reconcileChildFibersImpl (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:5799:393)
    at http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:5856:39
    at reconcileChildren (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:7439:51)
    at beginWork (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:8209:1573)
    at runWithFiberInDEV (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:3073:74)
    at performUnitOfWork (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:10243:97)
    at workLoopSync (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:10135:40)
    at renderRootSync (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:10118:13)
    at performWorkOnRoot (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:9877:56)
    at performWorkOnRootViaSchedulerTask (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:10826:9)
    at MessagePort.performWorkUntilDeadline (http://localhost:3000/_next/static/chunks/node_modules_next_dist_compiled_2ce9398a._.js:1982:64)
    at PlatformFeedbackPage (rsc://React/Server/C:%5CUsers%5CTom%5Cdev%5Cminerva%5C.next%5Cserver%5Cchunks%5Cssr%5C_d5c677bd._.js?18:93:270)