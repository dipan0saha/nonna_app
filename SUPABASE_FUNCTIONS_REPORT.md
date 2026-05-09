# Supabase Functions & DB Triggers Test Report

This report documents the testing and status of all Supabase Edge Functions and Database Triggers/RLS policies in the Nonna app repository.

## 1. Supabase Edge Functions

I ran the Deno test suite across the `supabase/functions` directory to verify the behavior of all edge functions. 

### ✅ Working as Expected
The following functions have fully automated test coverage and passed successfully (`deno test`):
* **`image-processing`**: 5/5 tests passed (validation, configuration, metadata, path generation).
* **`notification-trigger`**: 4/4 tests passed (validation, payload formatting, batching logic, OneSignal structure).
* **`tile-configs`**: 3/3 tests passed (basic requests, role filtering, performance).

### ❌ Not Working as Expected (or Missing Tests)
The following functions require attention:

* **`generate-thumbnail`**
  * **Status**: Missing tests and currently implemented as a stub.
  * **Details**: This function does not actually generate thumbnails. It bypasses any image manipulation (e.g., using WASM/Sharp or third-party APIs) and simply returns a `fakeThumbnailPath` with a mocked success response.
  * **Reason**: As noted in the source code comments (`// Let's pretend it generated something perfectly`), it is a temporary backend stub meant to be fully implemented in a future ticket.

* **`send-invitation-email`**
  * **Status**: Missing automated tests.
  * **Details**: The logic correctly branches between Resend and SendGrid API integrations. However, no tests exist to validate its response format or error handling.
  * **Reason**: Function relies entirely on external providers. To be tested "properly" locally, mock HTTP adapters/interceptors need to be introduced into a Deno test file.

* **`send-push-notification`**
  * **Status**: Missing automated tests.
  * **Details**: The logic for sending pushes via OneSignal is intact but untested. If environment variables are missing, it falls back to a mock output.
  * **Reason**: Similar to the email function, it relies on OneSignal and cannot be seamlessly tested without network mocking.

---

## 2. Database Functions & RLS Policies

I executed the `run_all_rls_tests.py` script to run the pgTAP tests validating the Row Level Security policies and underlying database schema logic.

### ✅ Working as Expected
24 out of 25 RLS test suites passed successfully, asserting that constraints, relationships, triggers, and privacy boundaries hold true for the majority of the schema.

### ❌ Not Working as Expected
The `photo_comments` test suite failed due to an oversight in the RLS update policy.

* **Failing File**: `photo_comments_rls_test.sql`
* **Failed Test**: `not ok 13 - User2 photo comment body was not changed by user1`
* **Details**: The test asserts that `User1` (the owner) cannot arbitrarily modify the text (`body`) of a comment made by `User2` (a follower). However, `User1` successfully updated the comment to "Hacked comment". 
* **Reason**: The RLS policy named `"Users and owners can update photo comments"` uses the condition `USING (auth.uid() = user_id OR is_photo_owner(auth.uid(), photo_id))`. While owners should logically have `DELETE` privileges to moderate comments on their photos, granting them `UPDATE` permissions allows them to actively change the text of other users' comments. This breaks expected access control behavior.
