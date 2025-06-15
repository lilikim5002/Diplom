FROM node:16-alpine AS client

WORKDIR /app/Textura_Front


COPY ["./Textura_Front/package*.json", "./"]
RUN npm install
COPY ["./Textura_Front", "./"]
RUN npm run build --prod


FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder

WORKDIR /src


COPY ["./Diplom_Back/API/Texture.csproj", "./Diplom_Back/API/"]
RUN dotnet restore "./Diplom_Back/API/Texture.csproj"


COPY . .

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
ENTRYPOINT ["dotnet", "Texture.dll"]