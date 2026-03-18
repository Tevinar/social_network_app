# Social Network App

Application Flutter de reseau social connectee a Supabase, utilisant la Clean Architecture, structuree avec BLoC, `get_it` et une organisation par feature. Le projet couvre l'authentification, la publication de blogs avec image, ainsi qu'une messagerie en temps reel.

Note: le nom du repository et le package Dart du projet sont `social_network_app`.

## Fonctionnalites

- Authentification par email / mot de passe avec persistance de session via Supabase Auth
- Redirection automatique selon l'etat de connexion
- Creation de blogs avec image, contenu, titre et selection de sujets
- Upload des images de blog dans Supabase Storage
- Fil de blogs pagine avec infinite scroll
- Synchronisation en temps reel des blogs via Supabase Realtime
- Creation de conversations a partir d'une selection d'utilisateurs
- Envoi et reception de messages en temps reel
- Pagination des conversations et des messages

## Stack technique

- Flutter / Dart
- `flutter_bloc` pour la gestion d'etat
- `get_it` pour l'injection de dependances
- `go_router` + `go_router_builder` pour le routage type-safe
- `supabase_flutter` pour l'auth, la base de donnees, le storage et le realtime
- `fpdart` pour les `Either`
- `talker` pour le logging
- `image_picker`, `intl`, `internet_connection_checker_plus`

## Architecture

Le projet suit une separation en couches par fonctionnalite:

```text
lib/
  app/
    bootstrap/
    logging/
    router/
    services/
    session/
  core/
    config/
    constants/
    errors/
    logging/
    network/
    services/
    theme/
    usecases/
    utils/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    blog/
      data/
      domain/
      presentation/
    chat/
      data/
      domain/
      presentation/
```

Chaque feature isole:

- `data`: datasource distantes, modeles, repository implementations
- `domain`: entites, contrats de repository, use cases
- `presentation`: pages, widgets, blocs et etats UI

## Prerequis

- Flutter SDK compatible avec `sdk: ^3.10.4`
- Un projet Supabase configure
- Une plateforme Flutter activee selon votre cible (`android`, `ios`, `web`, `macos`, `windows`, `linux`)

## Installation

```bash
flutter pub get
```

Creer ensuite un fichier `.env` a la racine du projet:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

## Configuration Supabase attendue

L'application s'appuie sur les ressources suivantes:

- Auth email / password active
- Bucket Storage public `blog_images`
- Tables:
  - `profiles`
  - `blogs`
  - `chats`
  - `chat_members`
  - `chat_messages`
- Fonctions RPC:
  - `create_chat_with_members`
  - `get_chat_by_members`
- Realtime active sur:
  - `blogs`
  - `chats`
  - `chat_messages`

Les noms sont references directement dans le code, il faut donc conserver cette convention ou adapter les constantes du dossier `lib/core/constants/supabase_schema`.

Important: le code ne cree pas de ligne dans `profiles` apres inscription. Il faut donc prevoir cote Supabase un mecanisme de synchronisation entre `auth.users` et `profiles` (par exemple via un trigger PostgreSQL) afin que le nom de l'utilisateur soit disponible dans les blogs et la messagerie.

### Champs utilises cote application

`profiles`

- `id`
- `name`
- `updated_at`

`blogs`

- `id`
- `title`
- `content`
- `image_url`
- `topics`
- `poster_id`
- `updated_at`

`chats`

- `id`
- `last_message_id`
- `last_message_at`

`chat_members`

- `chat_id`
- `member_id`
- `joined_at`

`chat_messages`

- `id`
- `chat_id`
- `author_id`
- `content`
- `created_at`
- `updated_at`

Le code suppose egalement des policies RLS coherentes, en particulier pour limiter l'acces aux conversations et aux messages de l'utilisateur connecte.

## Lancer le projet

```bash
flutter run
```

Exemples:

```bash
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

## Commandes utiles

Executer les tests:

```bash
flutter test
```

Regenerer les routes type-safe apres modification du routage:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Lancer la generation en mode watch:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Parcours utilisateur principal

1. L'utilisateur cree un compte ou se connecte.
2. La session globale est ecoutee par `AppUserCubit`.
3. Une fois connecte, il accede au shell principal avec deux onglets:
   - le fil de blogs
   - la messagerie
4. Il peut publier un blog avec image et sujets.
5. Il peut ouvrir une conversation existante ou en creer une nouvelle.
6. Les blogs, conversations et messages se mettent a jour en temps reel.

## Tests presentes

Le projet contient deja une base de tests unitaires et widgets, notamment sur:

- l'authentification
- les repositories de la couche data
- quelques utilitaires du dossier `core`

## Ameliorations possibles

- Ajouter un schema SQL ou des migrations Supabase versionnees
- Fournir un fichier `.env.example`
- Documenter les policies RLS attendues
- Ajouter des captures d'ecran ou une demo GIF
