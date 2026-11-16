name: Lumen OS Pro ISO bauen
on:
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 120
    steps:
      - uses: actions/checkout@v4
      - name: ISO bauen
        run: |
          docker run --rm --privileged -v "$PWD:/work" -w /work debian:bookworm bash -c "apt-get update && apt-get install -y sudo && chmod +x build-lumen-os.sh && ./build-lumen-os.sh"
      - name: Pruefsumme
        run: cd lumen-build && sha256sum lumen-os-pro-amd64.iso > lumen-os-pro-amd64.iso.sha256
      - uses: actions/upload-artifact@v4
        with:
          name: lumen-os-pro-amd64
          path: |
            lumen-build/lumen-os-pro-amd64.iso
            lumen-build/lumen-os-pro-amd64.iso.sha256
            lumen-build/build.log
