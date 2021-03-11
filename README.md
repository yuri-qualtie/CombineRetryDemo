It looks like having tryCatch + retry will create a retain cycle. [See issue](https://github.com/yuri-qualtie/CombineRetryDemo/issues/1)

Steps to reproduce:
 * Launch App - CombineRetryDem
 * Tap - "Load HTML" button
 * Wait for prints in console. For example: completed finished
 * Tap "Back" button
 * Run Debug Memory Graph 
 
 ![image](https://user-images.githubusercontent.com/22487637/110846655-e2e40e00-8260-11eb-8445-4cd39fb53bed.png)


**Expected**:
HTMLViewController is deallocated and de inited is printed in console
subscription is canceled and all the combine publishers are deallocated

**Actual**:
HTMLViewController is deallocated and de inited is printed in console
Retry and TryCatch are not deallocated and create retain cycle.


**Context**:
For our use case we are using a sequence of Combine operators to make a request to a server. In the case where the request fails (server responds with expired token/invalid etc) we want to refresh our token inside the .tryCatch and retry the entire sequence from the beginning. 

After experimenting we found that replacing retry by having all of our business logic inside the .tryCatch doesn't create a retain cycle but requires us to duplicate our sequence of operators. Is there a better approach we can use?
