# Microsoft365R <img src="man/figures/logo.png" align="right" width=150 />

Microsoft365R is intended to be a simple yet powerful R interface to [Microsoft 365](https://www.microsoft.com/en-us/microsoft-365) (formerly known as Office 365), leveraging the facilities provided by the [AzureGraph](https://cran.r-project.org/package=AzureGraph) package. Currently it enables access to data stored in [SharePoint Online](https://www.microsoft.com/en-au/microsoft-365/sharepoint/collaboration) sites and [OneDrive](https://www.microsoft.com/en-au/microsoft-365/onedrive/online-cloud-storage). Both personal OneDrive and OneDrive for Business are supported. Future versions may add support for Teams, Outlook and other Microsoft 365 services.

## OneDrive

To access your personal OneDrive, call the `personal_onedrive()` function. This uses your Internet browser to authenticate with OneDrive, in a similar manner to other web apps. You will see a screen asking you to grant permission for the AzureR Graph app to access your information.

Once the authentication is complete, `personal_onedrive()` returns an R6 client object of class `ms_drive`, which has methods for working with files and folders.

```r
od <- personal_onedrive()

# list files and folders
od$list_items()
od$list_items("Documents")

# upload and download files
od$download_file("Documents/myfile.docx")
od$upload_file("somedata.xlsx")

# create a folder
od$create_folder("Documents/newfolder")
```

You can open a file or folder in your browser with the `open_item()` method. For example, a Word document or Excel spreadsheet will open in Word or Excel Online, and a folder will be shown in OneDrive.

```r
od$open_item("Documents/myfile.docx")
```

You can look at the metadata properties for a file or folder with `get_item_properties()`. This returns an R6 object of class `ms_drive_item`; the properties themselves can be found under the `properties` field.

```r
file_props <- od$get_item_properties("Documents/myfile.docx")

# all metadata is stored as a list in 'properties'
file_props$properties
```

Similarly, you can change the metadata for a file with `set_item_properties()`. Provide the new properties as named arguments to the method. Not all properties can be changed; some, like the file size and last modified date, are read-only.

```r
# rename a file -- version control via filename is bad, mmkay
od$set_item_properties("Documents/myfile.docx", name="myfile version 2.docx")

# alternatively, you can call the file object's update() method
file_props$update(name="myfile version 2.docx")
```

To access OneDrive for Business call `business_onedrive()`. This also returns an object of class `ms_drive`, so the exact same methods are available as for personal OneDrive. Note that OneDrive for Business is technically part of SharePoint and requires a Microsoft 365 Business license.

```r
odb <- business_onedrive()

odb$list_items()
odb$open_item("myproject/demo.pptx")
```

## SharePoint

To access a SharePoint site, use the `sharepoint_site()` function and provide the site URL or ID.

```r
site <- sharepoint_site("https://myaadtenant.sharepoint.com/sites/my-site-name")
```

The client object has methods to retrieve drives and lists. To show all drives in a site, use the `list_drives()` method, and to retrieve a specific drive, use `get_drive()`. Each drive is an object of class `ms_drive`, just like the OneDrive clients above.

```r
# list of all document libraries under this site
site$list_drives()

# default document library
drv <- site$get_drive()

# same methods as for OneDrive
drv$list_items()
drv$open_item("myproject/demo.pptx")
```

To show all lists in a site, use the `get_lists()` method, and to retrieve a specific list, use `get_list()` and supply either the list name or ID.

```r
site$get_lists()

lst <- site$get_list("my-list")
```

You can retrieve the items in a list as a data frame, with `list_items()`. This has arguments `filter` and `select` to do row and column subsetting respectively. `filter` should be an OData expression provided as a string, and `select` should be a string containing a comma-separated list of columns. Any column names in the `filter` expression must be prefixed with `fields/` to distinguish them from item metadata.

```r
# return a data frame containing all list items
lst$list_items()

# get subset of rows and columns
lst$list_items(
    filter="startsWith(fields/firstname, 'John')",
    select="firstname,lastname,title"
)
```

Finally, you can retrieve subsites with `list_subsites()` and `get_subsite()`. These also return SharePoint site objects, so all the methods above are available for a subsite.

Currently, SharePointR only supports SharePoint Online, the cloud-hosted version of the product. Support for SharePoint Server (the on-premises version) may come at a later stage.

## Integration with AzureGraph

In addition to the client functions given above, SharePointR enhances the `az_user` and `az_group` classes that are part of AzureGraph, to let you access drives and sites directly from a user or group object.

`az_user` gains `list_drives()` and `get_drive()` methods. The first shows all the drives that the user has access to, including those that are shared from other users. The second retrieves a specific drive, by default the user's OneDrive. Whether these are personal or business drives depends on the tenant that was specified in `AzureGraph::get_graph_login()`/`create_graph_login()`: if the tenant was "consumers", it will be the personal OneDrive.

`az_group` gains `list_drives()`, `get_drive()` and `get_sharepoint_site()` methods. The first two do the same as for `az_user`: they retrieve the drive(s) for the group. The third method retrieves the SharePoint site associated with the group, if one exists.
