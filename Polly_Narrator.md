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
  