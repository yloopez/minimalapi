using Xunit;
using Moq;
using SixMinApi.Data;
using SixMinApi.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

public class CommandRepoTests
{
    [Fact]
    public async Task GetAllCommands_ReturnsCommands()
    {
        // Arrange
        var mockRepo = new Mock<ICommandRepo>();
        mockRepo.Setup(repo => repo.GetAllCommands())
            .ReturnsAsync(new List<Command>
            {
                new Command { Id = 1, HowTo = "Test", CommandLine = "echo", Platform = "Windows" }
            });

        // Act
        var result = await mockRepo.Object.GetAllCommands();

        // Assert
        Assert.Single(result);
        Assert.Equal("Test", result.First().HowTo);
    }
}