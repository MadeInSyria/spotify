module Spotify
  class API
    # @!group PlaylistContainer

    # Attach callbacks to the container, used for getting change notifications.
    #
    # @example
    #   callbacks = Spotify::PlaylistContainerCallbacks.new({
    #     container_loaded: proc { |playlist| puts "Container loaded!" },
    #   })
    #   Spotify.playlistcontainer_add_callbacks(container, callbacks, nil) # => :ok
    #
    # @note it is *very* important that the callbacks are not garbage collected before they are called!
    # @param [PlaylistContainer] container
    # @param [PlaylistContainerCallbacks] container_callbacks
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    attach_function :playlistcontainer_add_callbacks, [ PlaylistContainer, PlaylistContainerCallbacks.by_ref, :userdata ], :error

    # Remove container callbacks previously added with {#playlistcontainer_add_callbacks}.
    #
    # @see #playlistcontainer_add_callbacks
    # @param [PlaylistContainer] container
    # @param [PlaylistCallbacks] container_callbacks
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    attach_function :playlistcontainer_remove_callbacks, [ PlaylistContainer, PlaylistContainerCallbacks.by_ref, :userdata ], :error

    # @see #playlistcontainer_is_loaded
    # @see #playlistcontainer_playlist
    # @note if the container is not loaded, the function will always return 0.
    # @param [PlaylistContainer] container
    # @return [Integer] number of playlists in container
    attach_function :playlistcontainer_num_playlists, [ PlaylistContainer ], :int

    # @see #playlistcontainer_num_playlists
    # @note if index is out of range, the function always return nil.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @return [Playlist, nil] playlist at index
    attach_function :playlistcontainer_playlist, [ PlaylistContainer, :int ], Playlist

    # @see #playlistcontainer_num_playlists
    # @note if index is out of range, the function always return :playlist.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @return [Symbol] playlist type of playlist at index, one of :playlist, :start_folder, :end_folder, :placeholder
    attach_function :playlistcontainer_playlist_type, [ PlaylistContainer, :int ], :playlist_type

    # Retrieve folder name of a folder in a container.
    #
    # @example
    #   index = 0
    #   folder_name = FFI::MemoryPointer.new(:char, 255) do |folder_name_ptr|
    #     Spotify.playlistcontainer_playlist_folder_name(container, index, folder_name_ptr, folder_name_ptr.size)
    #     break folder_name_ptr.read_string.force_encoding("UTF-8")
    #   end
    #
    # @see #playlistcontainer_num_playlists
    # @note the spotify client appear to constrain the name to 255 chars, but the API has no such constraint.
    # @note if index is out of range, the function always return an empty string.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @param [FFI::Pointer<String>] name_pointer out parameter for folder name
    # @param [Integer] name_pointer_size
    # @return [Symbol] error code
    attach_function :playlistcontainer_playlist_folder_name, [ PlaylistContainer, :int, :buffer_out, :int ], :error

    # @note if the index is out of range, the function always return 0.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @return [Integer] folder id at index
    attach_function :playlistcontainer_playlist_folder_id, [ PlaylistContainer, :int ], :uint64

    # Add a new playlist to the end of the container.
    #
    # @note the name must not constist of only spaces, and it must be shorter than 256 bytes.
    # @param [PlaylistContainer] container
    # @param [String] playlist_name name of the playlist
    # @return [Playlist, nil] the new playlist, or nil if creation failed
    attach_function :playlistcontainer_add_new_playlist, [ PlaylistContainer, UTF8String ], Playlist

    # Add an existing playlist to the end of the container.
    #
    # @param [PlaylistContainer] container
    # @param [Link] link link to a playlist
    # @return [Playlist, nil] the playlist, or nil if the playlist already exists, or if the link was not a valid playlist link
    attach_function :playlistcontainer_add_playlist, [ PlaylistContainer, Link ], Playlist

    # Remove a playlist from a container.
    #
    # @note if you remove a folder marker, remove the other corresponding (start or stop) marker
    #       as well, or the playlist will be left in an inconsistent state.
    #
    # @note if the index is out of range, the function always return an error.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @return [Symbol] error code
    attach_function :playlistcontainer_remove_playlist, [ PlaylistContainer, :int ], :error

    # Move a playlist to another position in the container.
    #
    # @note if the index is out of range, the function always return an error.
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0...{#playlistcontainer_num_playlists}
    # @param [Integer] new_position
    # @param [Boolean] dry_run do not move the playlist, only check if it is possible
    # @return [Symbol] error code
    attach_function :playlistcontainer_move_playlist, [ PlaylistContainer, :int, :int, :bool ], :error

    # Create a new folder in the container.
    #
    # This creates a start_folder marker, and an end_folder marker right after it, at
    # specified index.
    #
    # @note you cannot rename folders, if you want to do so you have to destroy the folder and recreate it
    # @param [PlaylistContainer] container
    # @param [Integer] index number between 0..{#playlistcontainer_num_playlists}
    # @param [String] folder_name
    attach_function :playlistcontainer_add_folder, [ PlaylistContainer, :int, UTF8String ], :error

    # @param [PlaylistContainer] container
    # @return [User] owner of the container
    attach_function :playlistcontainer_owner, [ PlaylistContainer ], User

    # @param [PlaylistContainer] container
    # @return [Boolean] true if the container is loaded
    attach_function :playlistcontainer_is_loaded, [ PlaylistContainer ], :bool

    # Number of new tracks in playlist since {#playlistcontainer_clear_unseen_tracks} was called.
    #
    # @example number of unseen tracks in playlist
    #   Spotify.playlistcontainer_get_unseen_tracks(container, playlist, nil, 0) # => 279
    #
    # @example unseen tracks in playlist
    #   count = Spotify.playlistcontainer_get_unseen_tracks(container, playlist, nil, 0)
    #   tracks_array = FFI::MemoryPointer.new(Spotify::Track, count)
    #   total = Spotify.playlistcontainer_get_unseen_tracks(container, playlist, tracks_array, count)
    #   unseen_tracks = tracks_array.read_array_of_pointer(total).map do |track_pointer|
    #     # It is not yet fully known if you should use regular class, or retaining class, as libspotify
    #     # documentation does not state if the tracks need an additional reference or not. If in doubt,
    #     # I would take a chance with the .retaining_class. Worst case you'll have a memory leak.
    #     # Spotify::Track.from_native(track_pointer, nil)
    #     # Spotify::Track.retaining_class.from_native(track_pointer, nil)
    #   end
    #
    # @note it's not known if the track pointers should have Track.retaining_class or not, be careful!
    # @param [PlaylistContainer] container
    # @param [Playlist] playlist
    # @param [FFI::Pointer<Track>] tracks_pointer
    # @param [Integer] tracks_pointer_count
    # @return [Integer] actual number of unseen tracks, or -1 on failure
    attach_function :playlistcontainer_get_unseen_tracks, [ PlaylistContainer, Playlist, :array, :int ], :int

    # Clear unseen tracks for a playlist on a container
    #
    # This will cause the next{#playlistcontainer_get_unseen_tracks} call to return 0.
    #
    # @param [PlaylistContainer] container
    # @param [Playlist] playlist
    # @return [Integer] 0 on success, and -1 on failure
    attach_function :playlistcontainer_clear_unseen_tracks, [ PlaylistContainer, Playlist ], :int

    attach_function :playlistcontainer_add_ref, [ PlaylistContainer ], :error
    attach_function :playlistcontainer_release, [ PlaylistContainer ], :error
  end
end
