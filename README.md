# Ruby Base Image
We tend to need a wider range of Ruby versions than would be officially
supported by the Docker Hub Library "ruby" image.

## Adding a new Ruby
To add a new version like 3.6.2 to the build matrix, CI needs to know about the
new version and there needs to be a Dockerfile to build from. Assume that we
support two versions of Debian, "trixie" and "forky".

1. Add the `"3.6.2"` under the `"ruby-ver"` key in the matrix step in
   '.github/workflows/push.yml'

2. Create a folder for each Dockerfile of the new version:
   ```sh
   mkdir "3.6.2"
   mkdir "3.6.2/trixie"
   mkdir "3.6.2/forky"
   ```

3. There are two ways to point CI to Dockerfiles for the new versions::
   - Add new Dockerfiles at './3.6.2/trixie/Dockerfile' and './3.6.2/trixie/Dockerfile'
   - Create symlinks from one of the generic Dockerfiles using a command like:
     ```sh
     pushd 3.6.2/trixie
     ln -s ../../Dockerfile.openssl3 Dockerfile
     popd

     pushd 3.6.2/forky
     ln -s ../../Dockerfile.openssl3 Dockerfile
     popd
     ```

4. Commit your changes and push to see if they build!
