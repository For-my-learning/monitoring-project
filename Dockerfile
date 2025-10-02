FROM elixir:1.15

WORKDIR /app
# copy everything
COPY . /app

RUN mix local.hex --force && mix local.rebar --force && mix deps.get

EXPOSE 4000
ENV MIX_ENV=dev
CMD ["mix", "phx.server"]


