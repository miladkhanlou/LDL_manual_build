# 1. Derivatives and Fedora in LDL:
## What are derivitives:
    - Derivatives are files that are derived from original ones, such as medium and small-sized versions of objects in JP2 format.
    
    - Derivatives are used for various purposes, like creating thumbnails.
    
    - Instead of Drupal, Fedora is responsible for applying derivatives.


## What they do in LDL1:
    - On LDL1, derivatives are responsible for creating and managing different datastreams through a graphical user interface (GUI).
    
    - Files are managed by Fedora's RELS-EXT (Resource Description Framework in Fedora) which defines relationships between objects.
    
    - Datastreams are created as data is ingested into the system.
    
    - Fedora/RiSearch is used for resource indexing.
    
    - Fedora creates derivatives from original files and saves them according to configured workflows.
    
    - Islandora Tuque creates connections from Drupal to Islandora.


# 2. FEDORA AS A OBJECT MANAGER:
## FEDORA STORAGE USAGE IN LDL1:
    - deriviteves are being created and pushed pout to fedora storage location endpoint.

    -  we may need to configure drupal storage location where derivitives get saved on Database.
## Fedora Components and micro services:
### 1. Blazegraph relational database for relations:
- **1. Role:**
    - Responsible for creating RELS-EXT relationships deriviteves and saving it to the fedora endpont database at /fcrepo/rest

    - it can be queries in sparql an fedora endpoint like ldl one is on fedora/risearch and sent back the RELS-EXT to the storage location!  On LDL1 it is fedora location!
- **2- triplestore queries:**
    - Usually queries is being run that does showing content with relationships according to RDF files(RELS-EXT)

### Crayfish micro services:
Each microservice is responsible for different aspects of derivatives in Islandora:

### 1. Homarus(Audio/Video):
- **Role:**
    - It will create deriviteves of original Audio/Video files with specific formats
    - Then save it in a storage location that we define. ON LDL1 is Data/fedoradata
    - We can specify different storage location faster option
    - Configuration detail:
```sh
#file types:
mime_types:
    valid:
      - video/mp4
      - video/x-msvideo
      - video/ogg
      - audio/x-wav
      - audio/mpeg
      - audio/aac
      - image/jpeg
      - image/png
    default: video/mp4
#converted to format:
  mime_to_format:
    valid:
      - video/mp4_mp4
      - video/x-msvideo_avi
      - video/ogg_ogg
      - audio/x-wav_wav
      - audio/mpeg_mp3
      - audio/aac_m4a
      - image/jpeg_image2pipe
      - image/png_image2pipe
# Fedora resource:
fedora_resource:
  base_url: http://localhost:8080/fcrepo/rest
# logs
log:
  file: /var/log/islandora/homarus.log
#syn configuration
## path to syn public keys
## Credentials to connect to fedora endpoint (user and role), and a defined token
syn:
  config: /opt/fcrepo/config/syn-settings.xml
```

- **2- Houdini (image deriviteves):**
    - It will create deriviteves of original image files with specific formats.
    - Default format image/jpeg.
    - Then save it in a storage location that we define. ON LDL1 is Data/fedoradata.
    - We can specify different storage location faster option.
    - Configuration detail:
```sh
#1. services yaml configuration
#Valid file tyoe formats:
    app.formats.valid:
        - image/jpeg
        - image/png
        - image/tiff
        - image/jp2
    app.formats.default: image/jpeg

# 2. crayfish_commons package yaml configuration
# Fedora Endpoint:
  fedora_base_uri: 'http://localhost:8080/fcrepo/rest'

## path to syn that defines path to public keys and Credentials to connect to fedora endpoint (user and role), and a defined token
  syn_config: '/opt/fcrepo/config/syn-settings.xml'

# 3. monolog yaml configuration:
  handlers:
    houdini:
      type: rotating_file
      path: /var/log/islandora/Houdini.log
      level: DEBUG
      max_files: 1

# 4. security configuration(to enable and disable JWT token authentication)
## Enable JWT
    providers:
        jwt_user_provider:
            id: Islandora\Crayfish\Commons\Syn\JwtUserProvider #CHECK

    firewalls:
        dev: #CHECK
            pattern: ^/(_(profiler|wdt)|css|images|js)/
            security: false  
        main: #CHECK
            anonymous: false
            # Need stateless or it reloads the User based on a token.
            stateless: true

            provider: jwt_user_provider 
            guard:
                authenticators:
                    - Islandora\Crayfish\Commons\Syn\JwtAuthenticator

    access_control: #CHECK
        # - { path: ^/admin, roles: ROLE_ADMIN }
        # - { path: ^/profile, roles: ROLE_USER }
## Disable JWT:
    providers:
        jwt_user_provider:
            id: Islandora\Crayfish\Commons\Syn\JwtUserProvider
    firewalls:
        dev:
            pattern: ^/(_(profiler|wdt)|css|images|js)/
            security: false
        main:
            anonymous: true
            # Need stateless or it reloads the User based on a token.
            stateless: true
```
- 3. **Hypercube (OCR) -> pdf_to_text**
    - It will create deriviteves of original pdf files into text format!
    - Then save it in a storage location that we define. ON LDL1 is Data/fedoradata.
    - We can specify different storage location faster option.
    - Configuration detail:
```sh
hypercube:
  tesseract_executable: tesseract
  pdftotext_executable: pdftotext

#fodora, log and syn configuration:
fedora_resource:
  base_url: http://localhost:8080/fcrepo/rest
log:
  level: NOTICE
  file: /var/log/islandora/hypercube.log
syn:
  enable: true
  config: /opt/fcrepo/config/syn-settings.xml
```

- **4. Milliner (Fedora indexing)**
    - Milliner is responsible for synchronizing Fedora resources with their Drupal representations, essentially indexing Fedora objects in Drupal.
        
        - Synchronization:
            - Milliner ensures that when objects are created, updated, or deleted in Fedora, these changes are reflected in the corresponding Drupal entities.
            
            - This synchronization keeps the metadata and content in Fedora and Drupal 
        
        - Indexing Fedora Resources:
            - Milliner indexes Fedora resources in Drupal, allowing Drupal to understand and interact with Fedora-stored objects.

            - This includes updating Drupal's database with the necessary information about Fedora objects.

    - Configuration detail:
```sh
#The RDF predicate used to track the modified date of resources.
modified_date_predicate: http://schema.org/dateModified

#indicating whether to strip the JSON-LD format when processing Fedora resources.
#Stripping the JSON-LD format typically involves converting the data into a more simplified or plain JSON format that is easier to process within Drupal.
strip_format_jsonld: true

#Database connection settings for Crayfish services. This includes:
db.options: #CHECK #CREATE DB FOR CRAYFISH
  driver: pdo_pgsql
  host: 127.0.0.1
  port: 5432
  dbname: CRAYFISH_DB 
  user: CRAYFISH_DB_USER
  password: CRAYFISH_DB_PASSWORD

#Skip mentioning fedora base url.
#Skip syn and log configs
```
- **5. Recast (Drupal to Fedora URI re-writing)**
    - Responsible for rewriting Drupal URIs to Fedora URIs
    
    - Essential for maintaining the relationship between Drupal entities and Fedora resources

    - ensuring that the metadata and digital objects in Fedora can be correctly referenced and managed from Drupal.

    - More info:
        - **What are fedora resources:**
            - **Digital Objects:** (Images, Documentm audio, video files)

            - **Metadata** 
                - Descriptive metadata:
                
                provides information about the digital objects, such as title, creator, date, subject, and description.


                - Technical metadata:
                
                detailing the file format, size, resolution, and other technical aspects.


                - Administrative metadata:
                
                related to the management and preservation of the digital objects.
                

                - Rights metadata:
                
                specifying the intellectual property rights and usage permissions.


            - **RDF Relationships:**
        
            Relationships expressed using RDF (Resource Description Framework) that link digital objects to their metadata, to each other, and to external resources.


        - **how to keep Relationships Between Drupal Entities and Fedora Resources:**
            - Consistency:
            
            The metadata and content in Fedora are accurately reflected in Drupal. When a digital object is created, updated, or deleted in Fedora, the corresponding Drupal entity must be synchronized to reflect these changes.


            - Referencing:
            
            Drupal can reference and interact with Fedora resources. This includes fetching metadata, displaying digital objects, and managing links between related objects.


            - Indexing:
            
            Fedora resources are indexed in Drupal to make them searchable and accessible through the Drupal interface.


            - URI Rewriting:
            
            Recast rewrites Drupal URIs to Fedora URIs to ensure that links and references within Drupal point to the correct Fedora resources.

    - Configuration detail:
```sh
#Skip mentioning fedora and drupal base url.
#Skip syn and log

#Namespaces, list of namespaces used for various RDF predicates:
## Namespaces for RDF predicates. These define how various RDF properties and types are mapped.
  acl: "http://www.w3.org/ns/auth/acl#"
  fedora: "http://fedora.info/definitions/v4/repository#"
  ldp: "http://www.w3.org/ns/ldp#"
  memento: "http://mementoweb.org/ns#"
  pcdm: "http://pcdm.org/models#"
  pcdmuse: "http://pcdm.org/use#"
  webac: "http://fedora.info/definitions/v4/webac#"
  vcard: "http://www.w3.org/2006/vcard/ns#"
```

# 3. Troubleshooting Alpaca and fedor functionality for LDL2:
- For troubleshooting, check configurations that have **#CHECK** tags!
