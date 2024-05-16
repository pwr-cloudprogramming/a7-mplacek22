using TicTacToeCloud.Hubs;
using TicTacToeCloud.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration.AddEnvironmentVariables();
// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSignalR();

builder.Services.AddScoped<GameService, GameService>();
var albDnsName = Environment.GetEnvironmentVariable("ALB_DNS_NAME");
builder.Services.AddCors(options =>
{
    options.AddPolicy(name: "AllowSpecificOrigin",
        builder =>
        {
            builder.WithOrigins(
                "http://localhost:8080",
                "http://127.0.0.1:8080",
                "http://localhost:3000",
                "http://127.0.0.1:3000",
                $"http://{albDnsName}:3000",
                $"http://{albDnsName}:8080", 
                "http://mplacek22.us-east-1.elasticbeanstalk.com:8080",
                "http://mplacek22.us-east-1.elasticbeanstalk.com:3000",
                "frontend-app.us-east-1.elasticbeanstalk.com",
                "http://tictactoe-frontend.tictactoe.local:3000"
                )
                   .AllowAnyMethod()
                   .AllowAnyHeader()
                   .AllowCredentials();
        });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseAuthorization();

app.UseCors("AllowSpecificOrigin");

app.MapControllers();

app.MapHub<GameHub>("/gameplay");

app.Run();
