# VoxelForge

Minecraft-henkinen natiivi iOS voxel-sandbox, rakennettu SwiftUI + Metal -stackilla.

## Mitä mukana
- chunk-pohjainen maailma (`16x16x16`)
- world meshing vain näkyville faceille
- päävalikko, jossa **Luo maailma**
- kosketusohjaimet liikkumiseen ja katsomiseen
- riko / aseta / hyppy
- GitHub Actions workflow, joka pakkaa unsigned `.ipa`-tiedoston

## Rakenne
Pyynnön mukaan Swift-tiedostot on pidetty juuritasolla. Pakolliset erikoiskansiot:
- `VoxelForge.xcodeproj`
- `Assets.xcassets`
- `.github/workflows`

## Huomio
Tämä on hyvä runko, ei valmis Minecraft-klooni. Se piirtää useita chunkeja, mutta ei vielä tee:
- greedy meshing
- frustum culling
- pysyvää tallennusta
- inventorya
- procedural chunk streamingiä pelaajan liikkeen mukana

## Build Xcodella
1. Avaa `VoxelForge.xcodeproj`
2. Valitse iPhone tai iPad device / simulator
3. Build & Run

## GitHub Actions unsigned IPA
Workflow yrittää tehdä unsigned archive-buildin ja pakata siitä `.ipa`-tiedoston artefaktiksi.
