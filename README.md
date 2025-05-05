# CineVibe

CineVibe is a movie discovery app that combines traditional movie browsing with AI-powered recommendations. It allows users to find movies either by standard search or by describing their "vibe" or a movie scene to get personalized recommendations.

<div align="center">
  <video width="400" src="https://github.com/user-attachments/assets/c9ad1dfa-0f67-46f5-98d2-ef4b0bca4517" controls></video>
</div>

## Features

- **Home Screen**: Browse movies by categories (Popular, Top Rated, Now Playing, Upcoming)
- **Search Screen**: Two search modes:
  - Standard search: directly search for movies by title
  - **GenAI search**: describe your mood/vibe and get an AI-recommended movie that matches

## GenAI Search Experience

CineVibe's unique feature is the ability to find movies based on how you feel or a specific movie atmosphere you're craving. Here's how it works:

**You**: "I want something with rainy streets, neon lights, and a sense of loneliness"</br>
**CineVibe**: *processes your request through OpenAI and finds* "Blade Runner"

**You**: "A summer romance that reminds me of being young and carefree"</br>
**CineVibe**: *recommends* "Call Me By Your Name"

**You**: "I need a movie set in autumn with warm colors where people reconnect"</br>
**CineVibe**: *suggests* "When Harry Met Sally"

The app translates your vibes into specific movie recommendations, then fetches details from TMDB to show you the perfect match for your mood.

## Get Started

To run the project:

1. Clone this repository
2. Open `CineVibe.xcodeproj` in Xcode
3. Build and run on a simulator or physical device running iOS 13.0+

> [!NOTE]
> The project includes API keys for demonstration purposes. In a production environment, you would want to store these securely and not include them in the repository.

## API References

### The Movie Database (TMDB)
- [Movie lists](https://developer.themoviedb.org/reference/movie-now-playing-list)
- [Search movies](https://developer.themoviedb.org/reference/search-movie)
- [Images](https://developer.themoviedb.org/docs/image-basics)

### OpenAI API
- [Chat Completions](https://platform.openai.com/docs/api-reference/chat)

## Architecture

CineVibe follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Swift structs like `Movie` that represent the core data
- **Views**: UIKit-based view controllers and custom views
- **ViewModels**: Classes like `HomeViewModel` and `SearchViewModel` that handle business logic and data processing

## Design Patterns and Techniques

- **Dependency Injection**: Used throughout for better testability
- **Protocol-Oriented Programming**: Network services follow protocols for abstraction
- **Combine Framework**: For reactive data binding between ViewModels and Views
- **Diffable Data Sources**: For smooth collection view updates
- **Auto Layout with SnapKit**: For responsive UI design

### Network Layer

The networking layer is designed with protocol-oriented programming principles:

```
NetworkServiceProtocol
├── TMDBServiceProtocol
│   └── TMDBService
└── GenAIServiceProtocol
    └── GenAIService
```

This approach allows for easy testing with mock implementations and maintains separation of concerns.

### Key Components

- **NetworkService**: Base protocol for all network services
- **TMDBService**: Handles movie data fetching from TMDB API
- **GenAIService**: Manages communication with OpenAI for movie recommendations
- **SearchViewModel**: Coordinates between GenAI and TMDB services to provide movie recommendations
- **HomeViewModel**: Manages different movie list categories and data flow

## Dependencies

CineVibe uses Swift Package Manager for dependency management:

- **Alamofire**: Network requests handling
- **SnapKit**: Programmatic layout constraints
- **Kingfisher**: Efficient image loading and caching
- **SwiftLintPlugins**: Code quality enforcement

## Testing

The project includes three types of tests:

- **TMDBServiceTests**: Tests movie list and search functionality
- **GenAIServiceTests**: Tests AI text generation and movie recommendations
- **IntegrationTests**: Tests the full flow of getting AI recommendations and finding matching movies
