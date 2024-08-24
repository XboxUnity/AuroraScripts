---@meta

---Provides an interface for performing basic HTTP requests, handling response data, and URL encoding/decoding.
---
---This module requires the `http` permission to be enabled in the calling script's global `ScriptInfo` table.
---
---### Example
---
---```lua
---ScriptInfo = {
---  -- ...(other fields),
---  Permissions = { "http" }
---}
---```
---@class Http
Http = {}

---Represents the response data from an HTTP request.
---@class HttpResponse
---@field Url string The full URL of the request.
---@field Success boolean Indicates if the request was successful (HTTP status code 200).
---@field ResponseCode unsigned The HTTP status code.
---@field OutputPath string|nil The file path where the response was saved, if applicable.
---@field OutputSize unsigned|nil The size of the response data, if available.
---@field OutputData string|nil The response data as a string, if not saved to a file.
---@field Canceled boolean Indicates if the request was canceled.

---Represents the different callback reasons used in the HTTP progress routine.
---@enum HttpCallbackReason
HttpCallbackReason = {
    RequestOpened    = 1, --- The HTTP request has been opened.
    ChunkFinished    = 2, --- A chunk of data has been successfully transferred.
    RequestCompleted = 3, --- The HTTP request has been completed.
    RequestCanceled  = 4, --- The HTTP request has been canceled.
    RequestClosed    = 5, --- The HTTP request has been closed.
}

---@alias HttpProgressReturnCode ProgressCallbackReturnCode

---Callback function type used to track the progress of an HTTP download operation.
---The function receives the total size of the file being downloaded, the number of bytes transferred so far,
---and a reason code indicating the current state or phase of the download process.
---The function should return an `HttpProgressReturnCode` to control the continuation of the operation.
---@alias HttpProgressRoutine fun(totalFileSize: unsigned, totalBytesTransferred: unsigned, dwReason: HttpCallbackReason): HttpProgressReturnCode

---Sends a GET request to the specified URL, optionally saving the response data to a file.
---@param url string The URL to send the GET request to.
---@param outputPath? string Optional. The file path to save the response data to, relative to the script base path.
---@return HttpResponse|nil # A table containing the response data, or nil if the request failed.
---@since 0.6b
function Http.Get(url, outputPath) end

---Sends a GET request to the specified URL with a progress callback, optionally saving the response data to a file.
---@param url string The URL to send the GET request to.
---@param progressRoutine HttpProgressRoutine A callback function that receives progress updates and returns a Win32 error code to control the continuation of the download.
---@param outputPath? string Optional. The file path to save the response data to, relative to the script base path.
---@return HttpResponse|nil # A table containing the response data, or nil if the request failed.
---@since 0.7b
function Http.GetEx(url, progressRoutine, outputPath) end

---Sends a POST request to the specified URL with the provided POST variables, optionally saving the response data to a file.
---@param url string The URL to send the POST request to.
---@param postvars table A table containing the POST variables to send.
---@param outputPath? string Optional. The file path to save the response data to, relative to the script base path.
---@return HttpResponse|nil # A table containing the response data, or nil if the request failed.
---@since 0.6b
function Http.Post(url, postvars, outputPath) end

---Sends a POST request to the specified URL with the provided POST variables and a progress callback, optionally saving the response data to a file.
---@param url string The URL to send the POST request to.
---@param postvars table A table containing the POST variables to send.
---@param progressRoutine HttpProgressRoutine A callback function that receives progress updates and returns a Win32 error code to control the continuation of the download.
---@param outputPath? string Optional. The file path to save the response data to, relative to the script base path.
---@return HttpResponse|nil # A table containing the response data, or nil if the request failed.
---@since 0.7b
function Http.PostEx(url, postvars, progressRoutine, outputPath) end

---Encodes a string for use in a URL, making it safe to include as part of a query string or path.
---@param input string The string to encode.
---@return string # The encoded string.
---@since 0.6b
function Http.UrlEncode(input) end

---Decodes a URL-encoded string back into its original form.
---@param input string The string to decode.
---@return string # The decoded string.
---@since 0.6b
function Http.UrlDecode(input) end

return Http
