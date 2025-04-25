using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SixMinApi.Migrations
{
    public partial class SeedInitialData : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Commands",
                columns: new[] {"HowTo", "CommandLine", "Platform" },
                values: new object[,]
                {
                    {"List files", "ls -la", "Linux" },
                    {"Print working dir", "pwd", "Linux" },
                    {"Make directory", "mkdir new_folder", "Linux" }
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {

        }
    }
}
