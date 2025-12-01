[Русский](/README.md) 

# [Audiobooks Green](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4)

## About the App

[Audiobooks Green](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4) is an audiobook player application for Garmin devices. It's an unofficial client for your own [audiobookshelf](https://www.audiobookshelf.org/) server.

If you have an [audiobookshelf](https://www.audiobookshelf.org/) server and a Garmin watch with music support, you can install the [app](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4) from the [Connect IQ store](https://apps.garmin.com/) and use it completely free of charge.

## A Few Words About the Network Stack Implementation on Garmin Devices

Garmin devices have a very limited network stack with numerous constraints that affect functionality:

1.  **HTTPS Only:** Only secure (HTTPS) connections are supported. Establishing a standard HTTP connection on a real device (not an emulator) is impossible.
1.  **Image Proxy:** All images are downloaded through Garmin's proxy server. This behavior cannot be changed.
1.  **Data Format & Size:** Watches can only receive data (response body) in JSON and plain/text formats. The maximum response size a watch can handle is 8kB. If the response exceeds this limit, an error code -402 (minus 402) will be returned.
1.  **No Incoming Headers:** Access to incoming headers is completely absent, meaning there's no way to receive cookies.
1.  **Limited Outgoing Headers:** Capabilities for setting outgoing headers are extremely limited.
1.  **HTTP Methods:** Only GET, POST, DELETE, and PUT methods are implemented. Methods like PATCH or UPDATE are entirely missing.
1.  **POST Request Body:** The body of a POST request can ONLY be JSON. No text, XML, or binary formats are allowed.
1.  **Media File Formats:** Media files can only be downloaded in specific [formats](https://developer.garmin.com/connect-iq/api-docs/Toybox/Media.html). If the format is not supported, an error -1005 will occur.

## A Few Words About the Requirements and Implementation Specifics of [Audiobooks Green](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4)

From the previous section, the following directly arise:

1.  **Server Accessibility:** Your server must be accessible from the internet, have a domain name, and a valid certificate.
1.  **Proxy Requirement:** An intermediate proxy is REQUIRED for the application to function. This is because:
    *   It's fundamentally impossible on the Garmin stack to send listening progress to the audiobookshelf server, as this requires the PATCH method.
    *   The main issue, however, is not this. The primary problem is that the audiobookshelf API architecture is not optimized (this is my opinion, and I don't wish to offend anyone). The problem is that the audiobookshelf API returns enormous, HUGE amounts of data that are unnecessary in this context. Furthermore, the API largely lacks pagination.

        What I mean is: For example, I request a list of playlists on the server and naturally expect to receive JSON with `name` and `id` arrays. In reality, I receive a JSON file almost 3MB in size (remember Garmin's 8KB limit?). This JSON contains not only a list of all playlists with all their attributes but also a list of all books within those playlists with all their attributes, and each book contains a list of all media files with all their attributes. And there's no way to change this behavior. This is precisely why a proxy is needed – to receive this massive response, discard the junk, and transmit the data to the watch.

    In any case, Audiobooks Green by default makes a direct request to your audiobookshelf server first, and only upon receiving a -402 error (Serialized response was too large), it repeats the request through the proxy.

    If your audiobookshelf instance contains only one book, consisting of a single file and added to a single playlist, most requests will likely be executed directly, without the proxy. This excludes saving progress, of course.

    Media file downloads always occur directly from the audiobookshelf server, bypassing the proxy server.

## A Few Words About the Proxy Server

For the convenience of the app's users, I've embedded the proxy path into the application and provide access to my proxy server free of charge. I am a user of [Audiobooks Green](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4) and need to maintain the proxy server for myself. The load on it isn't significant, and I can share its resources with the community.

In return, I've received some shaming from the audiobookshelf community (quite fairly) because the app's operational scheme isn't transparent. I agree with this. There's a security risk to your server. After all, if I were an attacker, I could easily gain full access to your servers. And this is absolutely true.

Emphasis has been placed on the proxy's existence as the primary source of threat, for some reason. I don't understand why. Nothing prevents me from stealing your login credentials directly from the [Audiobooks Green](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4) app, right?
Similarly, I don't understand the fundamental difference between my application and any other installed from the store or from a package not built by you. Who can guarantee that a package compiled by someone else doesn't contain backdoors?

Any way, it's true that if you use a program from the [store](https://apps.garmin.com/en-EN/apps/0fbb79e9-1b2b-41e6-96a2-32679b484db4) and/or my proxy, your audiobookshelf instance is at risk. If I wanted to, I could easily steal your credentials and listen to your Terry Pratchett for free.

Don't want to take this **terrible risk**, but want to listen to books from your watch? I have 

## **Great News** For You!!!

You can now independently check ~7000 lines for any hidden backdoors, build the application yourself, and install it on your watch.

However, to be completely at ease, you'll need to do the same for the **[proxy server](https://github.com/fabrikant/AudiobooksGreenProxy)** and deploy it on your own hardware.

## Building the Application

### Install the [Connect IQ SDK](https://developer.garmin.com/connect-iq/overview/)

Installation instructions can be found [here](https://developer.garmin.com/connect-iq/sdk/) and [here](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/).

### Copy the code from this repository to your machine using any convenient method

In the **source/** folder, find the `Local.mc.example` file, copy it as `Local.mc`, and optionally, following the comments in the file, fill it with your own values.

You can leave the default values. In this case, you won't be able to receive debug messages via Telegram, and you'll have to enter the proxy address in the menu while the application is running.

### Build the application and copy it to your device

Follow the [instructions](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/) from the official website.

## Installing Your Own Proxy Server

You can find the source code and installation instructions for your own proxy server by following **[this link](https://github.com/fabrikant/AudiobooksGreenProxy)**.
