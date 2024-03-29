% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ms_chat_message.R
\docType{class}
\name{ms_chat_message}
\alias{ms_chat_message}
\title{Teams chat message}
\format{
An R6 object of class \code{ms_chat_message}, inheriting from \code{ms_object}.
}
\description{
Class representing a message in a Teams channel. Currently Microsoft365R only supports channels, not chats between individuals.
}
\section{Fields}{

\itemize{
\item \code{token}: The token used to authenticate with the Graph host.
\item \code{tenant}: The Azure Active Directory tenant for the parent drive.
\item \code{type}: Always "Teams message" for a chat message object.
\item \code{properties}: The item properties (metadata).
}
}

\section{Methods}{

\itemize{
\item \code{new(...)}: Initialize a new object. Do not call this directly; see 'Initialization' below.
\item \code{delete(confirm=TRUE)}: Delete this message. Currently the Graph API does not support deleting Teams messages, so this method is disabled.
\item \code{update(...)}: Update the message's properties (metadata) in Microsoft Graph.
\item \code{do_operation(...)}: Carry out an arbitrary operation on the message.
\item \code{sync_fields()}: Synchronise the R object with the message metadata in Microsoft Graph.
\item \code{send_reply(body, content_type, attachments)}: Sends a reply to the message. See below.
\item \code{list_replies(filter=NULL, n=50)}: List the replies to this message. By default, this is limited to the 50 most recent replies; set the \code{n} argument to change this.
\item \code{get_reply(message_id)}: Retrieves a specific reply to the message.
\item \code{delete_reply(message_id, confirm=TRUE)}: Deletes a reply to the message. Currently the Graph API does not support deleting Teams messages, so this method is disabled.
}
}

\section{Initialization}{

Creating new objects of this class should be done via the \code{get_message} and \code{list_messages} method of the \code{\link{ms_team}} class. Calling the \code{new()} method for this class only constructs the R object; it does not call the Microsoft Graph API to retrieve or create the actual message.
}

\section{Replying to a message}{

To reply to a message, use the \code{send_reply()} method. This has arguments:
\itemize{
\item \code{body}: The body of the message. This should be a character vector, which will be concatenated into a single string with newline separators. The body can be either plain text or HTML formatted.
\item \code{content_type}: Either "text" (the default) or "html".
\item \code{attachments}: Optional vector of filenames.
\item \code{inline}: Optional vector of image filenames that will be inserted into the body of the message. The images must be PNG or JPEG, and the \code{content_type} argument must be "html" to include inline content.
\item \code{mentions}: Optional vector of @mentions that will be inserted into the body of the message. This should be either an object of one of the following classes, or a list of the same: \code{\link{az_user}}, \code{\link{ms_team}}, \code{\link{ms_channel}}, \code{\link{ms_team_member}}. The \code{content_type} argument must be "html" to include mentions.
}

Teams channels don't support nested replies, so any methods dealing with replies will fail if the message object is itself a reply.

Note that message attachments are actually uploaded to the channel's file listing (a directory in the team's primary shared document folder). Support for attachments is somewhat experimental, so if you want to be sure that it works, upload the file separately using the channel's \code{upload_file()} method.
}

\section{List methods}{

All \verb{list_*} methods have \code{filter} and \code{n} arguments to limit the number of results. The former should be an \href{https://learn.microsoft.com/en-us/graph/query-parameters#filter-parameter}{OData expression} as a string to filter the result set on. The latter should be a number setting the maximum number of (filtered) results to return. The default values are \code{filter=NULL} and \code{n=Inf}. If \code{n=NULL}, the \code{ms_graph_pager} iterator object is returned instead to allow manual iteration over the results.

Support in the underlying Graph API for OData queries is patchy. Not all endpoints that return lists of objects support filtering, and if they do, they may not allow all of the defined operators. If your filtering expression results in an error, you can carry out the operation without filtering and then filter the results on the client side.
}

\examples{
\dontrun{

myteam <- get_team("my team")

chan <- myteam$get_channel()
msg <- chan$list_messages()[[1]]
msg$list_replies()
msg$send_reply("Reply from R")

}
}
\seealso{
\code{\link{ms_team}}, \code{\link{ms_channel}}

\href{https://learn.microsoft.com/en-us/graph/overview}{Microsoft Graph overview},
\href{https://learn.microsoft.com/en-us/graph/api/resources/teams-api-overview?view=graph-rest-1.0}{Microsoft Teams API reference}
}
