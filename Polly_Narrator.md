# Polly Narrator

Project will access Amazon Polly service and store the audio output in a S3 bucket using a Lambda function.

## Steps to be Performed

1. Exploring Amazon Polly
2. Creating an IAM Role
3. Creating an S3 Bucket
4. Writing Lambda function code
5. CHecking the output of Amazon Polly

## Services that will be used

- Amazon Polly: converts text to life like speech with customizable features
- Amazon Management Console: manages accounts and configures amazon polly
- AWS IAM: Ensures secure access by managing user permissions

## Create an IAM Role

- **Step 1:** Navigate to Access Management and Create a Role for Lambda
- **Step 2:** Select the AmazonPolly FullAccess, AmazonS3FullAccess, and AWSLambdaBasicExecutionRole permissions
- **Step 3:** Create role after review

## Create S3 Bucket

- **Step 1:** Go to S3 in console and create a bucket and leave all settings as default

## Create a Lambda function

- **Step 1:** Go to Lambda in the console and create a new function from scratch  
Choose the Node.js 22.x as the runtime environment  
Toggle the "Change default configuration role" and check "Use existing role"  
Choose the role created in the previous section
Create function
- **Step 2:** Replace code with this code:

```javascript
import { PollyClient, SynthesizeSpeechCommand } from "@aws-sdk/client-polly";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";

// Initialize clients
const pollyClient = new PollyClient({});
const s3Client = new S3Client({});

export async function handler(event) {
    try {
        // Extract text input from the event
        const text = event.text;

        // Generate speech using Polly
        const pollyParams = {
            Text: text,
            OutputFormat: "mp3",
            VoiceId: "Joanna",
        };

        const synthesizeCommand = new SynthesizeSpeechCommand(pollyParams);
        const pollyResponse = await pollyClient.send(synthesizeCommand);

        // Validate Polly response
        if (!pollyResponse.AudioStream) {
            throw new Error("Polly did not return audio data.");
        }

        // Convert AudioStream to a buffer
        const audioBuffer = await streamToBuffer(pollyResponse.AudioStream);

        // Specify S3 parameters with ContentLength
        const key = `audio-${Date.now()}.mp3`;
        const s3Params = {
            Bucket: "pollyaudiofilestorageproject3", // Replace with your S3 bucket name
            Key: key,
            Body: audioBuffer,
            ContentType: "audio/mpeg",
            ContentLength: audioBuffer.length, // Set content length explicitly
        };

        // Upload the audio file to S3
        const putCommand = new PutObjectCommand(s3Params);
        await s3Client.send(putCommand);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: `Audio stored as ${key}` }),
        };
    } catch (error) {
        console.error("Error:", error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: "Internal server error", error: error.message }),
        };
    }
}

// Helper function: Convert a readable stream to a buffer
async function streamToBuffer(stream) {
    const chunks = [];
    for await (const chunk of stream) {
        chunks.push(chunk);
    }
    return Buffer.concat(chunks);
}
```

- **Step 3:** Deploy code to save changes
  - **Notes: What this code is doing  
  Input Processing: Lambda receives the text input from the test event  
  Speech Generation: Amazon Polly converts the text into natural speech using Joanna voice  
  S3 Upload: File automatically uploads to your S3 bucket with timestamp-based filename  
  Confirmation: function returns success message with stored file location  
  Access: Navigates to S3 bucket to download and listen generated audio  
  Timeline: complete process takes just a few seconds**
- **Step 4:** Configure a test event for the Lambda function by adding a Test Event under the Deploy and Test buttons  
Test should look like this:

```json
{
    "text":"Example here"
}
```

## Check output

- **Step 1:** Go to the S3 bucket and check the test item  
- **Step 2:** Click on the Open button on the above ribbon  
This will open the mp3 on a webpage and play the audio

## Conclusion and my thoughts

My first project has been completed. I ran into trouble as the guide recommended to change the Lambda function's index.mjs to index.js. After seeing the error flag it looked like all I needed to do was revert it back and it worked afterward and I removed that step from my notes here.  
  
  After I get through a few projects done and learn Terraform I would like to come back to this project and build it up a bit more for practice. I'd like to take the guide's advice and build a website that takes in a user's request and distributes it back on the website.
  
## What I learned Terraforming this

So, I did not take the guide's advice yet about building it up into a website or anything, but I did succesfully turn this into Terraform. I really learned a lot on this one especially in regard to IAM resources. I initially had made each policy I needed as a resource, and I thought to myself that this wouldn't work. I didn't really see a way to apply these to one role, but I thought about how the design of the GUI was and thought to myself I should be able to select multiple policies in this too. I did a little research with the help of AI and found the for_each meta-argument as well as the local block. This turned out really well as this made it scalable as well. I for whatever reason another policy needs to be added, someon can just add it to the locals block.

Building up the other resources wasn't that bad either, but I had to figure out how you would pass a file with code to Lambda. I did a little more research and came across the archive provider and data block. I learnbed the ${path.module} is a way to traverse with the current directory of the terraform file it is written in as being the reference point. After I applied this and set it as the filename for Lambda, I almost applied terraform when I realized that I needed to get Lambda to recognize the bucket name to store the sound files, since it would be auto-generated and I couldn't define a static name in the code. Looking at my first project I knew that method wouldn't work, since the code is running in a serverless Lambda function. But, after doing a bit of research and a little help from AI I found out that I could still set it as an environemnt variable and pass it into the javascript code. To my best understanding Terraform uses a data-flow execution model, or in other words its order of operations are dependent on what each resource is referencing. So in this case the S3 bucket should have been built before Lambda that way the environment variable I set in Lambda should set the auto-generated name in Lamba's environment and then the code set to reference the variable AUDIO_BUCKET_NAME will be able to find it and apply.

And, lastly I found that I had to change the javascript from javascript (js) to module javascript (.mjs). There was an error encountered during the lambda running where it couldn't import a module, as the latest iterattion of Javascript could not do it without a bit more coding, and I found it easier to modify the file to module javascript (.mjs) instead. It was really strange though causet the manual way of doing this I didn't need to change that, but maybe making it through the GUI made it where something else automatically managed that part, although I couldn't really find out why. This will need more research when I get more time, but for now I plan to keep moving forward with my projects in order to get more terraform and AWS practice.