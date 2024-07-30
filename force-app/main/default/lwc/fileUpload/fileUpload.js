import { LightningElement, api } from 'lwc';
// import LightningModal from 'lightning/modal'

// Import apex class
import fileCreate from '@salesforce/apex/fileUpload.fileCreate'

export default class FileUpload extends LightningElement {

    @api formats // store the allowed formats (".pdf, .doc")
    @api recordId // store the record Id where to store the file in
    @api label // store the label appearing on top of the component
    @api uploadButton = false // if to show "upload file" button
    @api uploadModal = false // if to show "upload file" modal
    @api modalHeader // store the modal header
    openModal // displays the modal on the screen
    fileUploaded // if file is uploaded
    fileData = {} // store the file name and base64

    // Return true for images
    get image () {
        return  this.fileData ?
                (this.fileData.fileType == 'image' ? true : false) : false
    }

    // After uploading a file
    handleFileUpload (event) {
        
        // Hide success message
        this.fileUploaded = false
        
        const file = event.target.files[0]
        if (file) {
            var reader = new FileReader()
            reader.readAsDataURL(file)

            reader.onload = () => {
                this.fileData = {
                    'fileName': file.name,
                    'base64' : reader.result, // Full Base 64
                    'base64AfterComma' : reader.result.split(',')[1], // to get the part of base64 after the comma (image/png;base64,iVBORw0..)
                    'fileSize' : file.size,
                    'fileType' : file.type.split('/')[0], // to get the type only ('image/png' -> 'image')
                    'fileFormat' : file.type.split('/')[1] // to get the format only ('image/png' -> 'png')
                }

                // Set Height and Width for Images
                if (this.fileData.fileType == 'image') {

                    // Creating an image object and populate it with the uploaded file
                    var img = new Image();
                    img.src = reader.result

                    img.onload = () => {
                        this.fileData = {...this.fileData, 
                            'fileHeight' : img.naturalHeight,
                            'fileWidth' : img.naturalWidth
                        }
                    }
                }

                // After Uploading a file for the direct onload
                if (this.uploadModal) {
                    this.openModal = true
                }

                // After Uploading a file for the popup method
                if (! this.uploadButton && !this.uploadModal) {
                    this.createFile ()
                }
            }
        }
    }


    // After clicking the "Remove File"
    handleRemove () {
        this.fileData = {} 
    }

    // After clicking the "Upload File"
    handleUpload () {
        this.createFile ()
    }

    // After clicking the "Upload" on the modal
    handleModalUpload () {
        this.createFile ()
        this.openModal = false

    }

    // After clicking the "Close" on the modal
    handleModalClose () {
        this.fileData = {} 
        this.openModal = false
    }

    // Creates file and attach to record
    createFile () {
        const {base64AfterComma, fileName} = this.fileData
        const recordId = this.recordId

        // call apex
        fileCreate({base64AfterComma, fileName, recordId}).then(result=>{
            console.log( `${result} File created successfully`)
        })

        // Clear file Data
        if (this.uploadButton || this.uploadModal) // When file upload is onload the data should not be cleared so it will display on the element
            this.fileData = {} 

        // Show success message
        this.fileUploaded = true
    }
}