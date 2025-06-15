FROM node:16-alpine AS client

WORKDIR /app/Textura_Front

COPY ./Textura_Front/package*.json ./

RUN npm install --frozen-lockfile

COPY ./Textura_Front ./

RUN npm run build --prod


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder

WORKDIR /src

COPY ["./Diplom_Back/API/Texture.csproj", "./"]
COPY ["./Diplom_Back/API/appsettings.json", "./Diplom_Back/API/"]
COPY ["./Diplom_Back/API/Program.cs", "./Diplom_Back/API/"]
COPY ["./Diplom_Back/API/Controllers/", "./Diplom_Back/API/Controllers/"]
COPY ["./Diplom_Back/API/Models/", "./Diplom_Back/API/Models/"]
COPY ["./Diplom_Back/API/Services/", "./Diplom_Back/API/Services/"]
COPY ["./Diplom_Back/API/Data/", "./Diplom_Back/API/Data/"]

RUN dotnet restore "./Texture.csproj"



WORKDIR "/src/Diplom_Back/API"
RUN dotnet build "Texture.csproj" -c Release -o /app/build


FROM builder AS publish

WORKDIR "/src/Diplom_Back/API"
RUN dotnet publish "Texture.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final

WORKDIR /app

COPY --from=publish /app/publish .
COPY --from=client /app/Textura_Front/dist ./wwwroot

EXPOSE 5000


HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["dotnet", "Texture.dll"]