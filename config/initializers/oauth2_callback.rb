module OmniAuth
  # The Strategy is the base unit of OmniAuth's ability to
  # wrangle multiple providers. Each strategy provided by
  # OmniAuth includes this mixin to gain the default functionality
  # necessary to be compatible with the OmniAuth library.
  module Strategy

    def full_host
      "https://104.131.149.93"
    end
  end
end
